#!/bin/bash

# 定义路径
ICLOUD_DESKTOP="/Users/linkunkun/Library/Mobile Documents/com~apple~CloudDocs/Desktop"
ICLOUD_DOCS="/Users/linkunkun/Library/Mobile Documents/com~apple~CloudDocs/Documents"
LOCAL_DESKTOP="/Users/linkunkun/Desktop"
LOCAL_DOCS="/Users/linkunkun/Documents"

echo "🚀 开始将 iCloud 文件搬回本地..."

# --- 处理桌面文件 ---
if [ -d "$ICLOUD_DESKTOP" ]; then
    # 检查目录下是否有文件（包括隐藏文件）
    if [ "$(ls -A "$ICLOUD_DESKTOP")" ]; then
        echo "📂 正在移动 iCloud 桌面文件 -> 本地桌面..."
        # 移动文件，-n 表示不覆盖已存在的文件
        mv -n "$ICLOUD_DESKTOP"/* "$LOCAL_DESKTOP/" 2>/dev/null
        # 再次检查是否有隐藏文件残留（以 . 开头的文件）
        mv -n "$ICLOUD_DESKTOP"/.* "$LOCAL_DESKTOP/" 2>/dev/null
        echo "✅ 桌面文件移动完成。"
    else
        echo "ℹ️  iCloud 桌面文件夹是空的，无需移动。"
    fi
else
    echo "⚠️  未找到 iCloud 桌面文件夹。"
fi

# --- 处理文稿文件 ---
if [ -d "$ICLOUD_DOCS" ]; then
    if [ "$(ls -A "$ICLOUD_DOCS")" ]; then
        echo "📄 正在移动 iCloud 文稿文件 -> 本地文稿..."
        mv -n "$ICLOUD_DOCS"/* "$LOCAL_DOCS/" 2>/dev/null
        mv -n "$ICLOUD_DOCS"/.* "$LOCAL_DOCS/" 2>/dev/null
        echo "✅ 文稿文件移动完成。"
    else
        echo "ℹ️  iCloud 文稿文件夹是空的，无需移动。"
    fi
else
    echo "⚠️  未找到 iCloud 文稿文件夹。"
fi

echo "🎉 所有操作执行完毕！请检查本地桌面和文稿文件夹。"