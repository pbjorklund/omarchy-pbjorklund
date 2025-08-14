#!/bin/bash
set -e

# Install Claude Code
echo "Installing Claude Code..."

# Check if Claude Code is already installed
if command -v claude-code &>/dev/null; then
    echo "Claude Code already installed"
    return 0
fi

# Install Claude Code via AUR
if command -v yay &>/dev/null; then
    echo "Installing Claude Code via AUR..."
    yay -S --noconfirm claude-code >/dev/null 2>&1
    echo "Claude Code installation completed"
else
    echo "ERROR: yay not found - please ensure AUR helper is installed"
    return 1
fi