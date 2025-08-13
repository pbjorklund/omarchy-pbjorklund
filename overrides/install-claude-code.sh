#!/bin/bash
set -e

# Install Claude Code CLI
if ! command -v npm &> /dev/null; then
    echo "npm not found! Please ensure Node.js is installed first."
    exit 1
fi

npm install -g @anthropic-ai/claude-cli