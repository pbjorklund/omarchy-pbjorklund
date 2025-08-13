#!/bin/bash

# Install and configure 1Password CLI with SSH integration
set -e

# Install 1Password CLI from AUR (skip if already installed)
if ! pacman -Q 1password-cli >/dev/null 2>&1; then
    yay -S --noconfirm 1password-cli
fi

# Enable 1Password SSH agent in shell profiles
if ! grep -q "SSH_AUTH_SOCK=~/.1password/agent.sock" ~/.bashrc 2>/dev/null; then
    echo 'export SSH_AUTH_SOCK=~/.1password/agent.sock' >> ~/.bashrc
fi
if ! grep -q "SSH_AUTH_SOCK=~/.1password/agent.sock" ~/.zshrc 2>/dev/null; then
    echo 'export SSH_AUTH_SOCK=~/.1password/agent.sock' >> ~/.zshrc
fi

# Configure SSH to use 1Password agent
mkdir -p ~/.ssh
if ! grep -q "1Password SSH Agent" ~/.ssh/config 2>/dev/null; then
    cat >> ~/.ssh/config << 'EOF'

# 1Password SSH Agent
Host *
    IdentityAgent ~/.1password/agent.sock
EOF
fi

# Configure git to use SSH for GitHub
git config --global url."ssh://git@github.com/".insteadOf "https://github.com/"