#!/bin/bash
set -e

# Configure passwordless sudo
echo "Configuring passwordless sudo..."

if sudo -n true 2>/dev/null; then
    echo "✓ Passwordless sudo already enabled"
else
    echo "Setting up passwordless sudo..."
    echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$(whoami)" > "$LOG_DIR/sudo-setup.log" 2>&1
    echo "✓ Passwordless sudo enabled"
fi