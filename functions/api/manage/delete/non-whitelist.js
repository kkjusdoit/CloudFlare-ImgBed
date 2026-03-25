import { batchRemoveFilesFromIndex, readIndex } from "../../../utils/indexManager.js";
import { deleteManagedFile } from "./[[path]].js";

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
};

export async function onRequest(context) {
    const { request, waitUntil, env } = context;
    const url = new URL(request.url);

    const dir = normalizeDir(url.searchParams.get('dir') || '');
    const search = decodeURIComponent(url.searchParams.get('search') || '').trim();
    const includeTags = splitTags(url.searchParams.get('includeTags'));
    const excludeTags = splitTags(url.searchParams.get('excludeTags'));
    const channel = url.searchParams.get('channel') || 'TelegramNew';

    try {
        const result = await readIndex(context, {
            directory: dir,
            search,
            channel,
            includeTags,
            excludeTags,
            count: -1,
            start: 0,
            includeSubdirFiles: true
        });

        if (!result.success) {
            throw new Error(result.error || 'Failed to read index');
        }

        const targets = result.files.filter(file => file.metadata?.ListType !== 'White');
        const deletedFiles = [];
        const failedFiles = [];

        for (const file of targets) {
            const fileId = file.id;
            const cdnUrl = `https://${url.hostname}/file/${fileId}`;
            const success = await deleteManagedFile(env, fileId, cdnUrl, url);

            if (success) {
                deletedFiles.push(fileId);
            } else {
                failedFiles.push(fileId);
            }
        }

        if (deletedFiles.length > 0) {
            waitUntil(batchRemoveFilesFromIndex(context, deletedFiles));
        }

        return new Response(JSON.stringify({
            success: true,
            channel,
            dir,
            search,
            scanned: result.files.length,
            deletedCount: deletedFiles.length,
            failedCount: failedFiles.length,
            deleted: deletedFiles,
            failed: failedFiles
        }), {
            headers: { 'Content-Type': 'application/json', ...corsHeaders }
        });
    } catch (error) {
        console.error('Failed to delete non-whitelist files:', error);
        return new Response(JSON.stringify({
            success: false,
            error: error.message
        }), {
            status: 500,
            headers: { 'Content-Type': 'application/json', ...corsHeaders }
        });
    }
}

function splitTags(value) {
    return value ? value.split(',').map(tag => tag.trim()).filter(Boolean) : [];
}

function normalizeDir(dir) {
    if (dir.startsWith('/')) {
        dir = dir.slice(1);
    }

    if (dir && !dir.endsWith('/')) {
        dir += '/';
    }

    return dir;
}
