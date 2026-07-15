#!/bin/bash
TARGET_FILE="$HOME/.config/opencode/opencode.json"
mkdir -p "$(dirname "$TARGET_FILE")"
cat > "$TARGET_FILE" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "routerpark": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "RouterPark",
      "options": {
        "baseURL": "https://any.routerpark.com/openai/v1",
        "apiKey": "sk-FJ4D0OKnODCwNzgkmkpHZ8SEqHmpw6HbTWAw34bDbhXog8fC"
      },
      "models": {
        "claude-sonnet-4-5": {},
        "gpt-5-high": {}
      }
    }
  }
}
EOF
echo "Configuration fixed at $TARGET_FILE"
