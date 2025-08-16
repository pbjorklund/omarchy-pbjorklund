#!/bin/bash

set -e

# Install terminal tools
if ! command -v tmux &> /dev/null; then
    yay -S --noconfirm tmux < /dev/null
fi

if ! command -v zellij &> /dev/null; then
    yay -S --noconfirm zellij < /dev/null
fi

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi