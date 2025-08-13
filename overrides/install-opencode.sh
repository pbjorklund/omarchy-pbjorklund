#!/bin/bash

# Install OpenCode CLI tool
set -e

# Check if opencode is already installed
if command -v opencode >/dev/null 2>&1; then
    echo "OpenCode already installed"
    return 0
fi

# Install OpenCode
echo "Installing OpenCode..."
if ! curl -fsSL https://opencode.ai/install | bash; then
    echo "ERROR: Failed to install OpenCode"
    return 1
fi

echo "OpenCode installation completed"