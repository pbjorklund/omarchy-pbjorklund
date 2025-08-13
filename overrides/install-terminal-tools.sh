#!/bin/bash

set -e

# Install terminal tools
if ! command -v tmux &> /dev/null; then
    sudo pacman -S --noconfirm tmux
fi

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi