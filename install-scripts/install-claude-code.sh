#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install Claude Code
show_action "Installing Claude Code"

# Check if Claude Code is already installed
if command -v claude &>/dev/null; then
    show_skip "Claude Code already installed"
    exit 0
fi

# Install Claude Code via AUR
if command -v yay &>/dev/null; then
    echo "Installing Claude Code via AUR..."
    log_command "yay -S --noconfirm claude-code" "claude-code-install" "Claude Code installation completed" "Claude Code installation failed"
else
    show_error "yay not found - please ensure AUR helper is installed"
    exit 1
fi