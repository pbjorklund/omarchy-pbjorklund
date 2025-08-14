#!/bin/bash

# Install and configure 1Password CLI with SSH integration
set -e

echo "Configuring 1Password CLI..."

# Check if 1Password desktop app is available
if ! command -v 1password >/dev/null 2>&1; then
    echo "WARNING: 1Password desktop app not found"
    echo "Please install 1Password desktop app and enable SSH agent in Developer settings"
    echo "Visit: https://1password.com/downloads/linux/"
fi

# Remind about keyring setup
echo "NOTE: If 1Password asks about keyring integration, use Seahorse to create a default keyring first"

# Install 1Password CLI from AUR (skip if already installed)
if ! pacman -Q 1password-cli >/dev/null 2>&1; then
    echo "Installing 1Password CLI..."
    yay -S --noconfirm 1password-cli
else
    echo "1Password CLI already installed"
fi

# Enable 1Password SSH agent in shell profiles
echo "Configuring SSH agent integration..."
if ! grep -q "SSH_AUTH_SOCK=~/.1password/agent.sock" ~/.bashrc 2>/dev/null; then
    echo 'export SSH_AUTH_SOCK=~/.1password/agent.sock' >> ~/.bashrc
    echo "Added SSH agent config to .bashrc"
fi
if ! grep -q "SSH_AUTH_SOCK=~/.1password/agent.sock" ~/.zshrc 2>/dev/null; then
    echo 'export SSH_AUTH_SOCK=~/.1password/agent.sock' >> ~/.zshrc
    echo "Added SSH agent config to .zshrc"
fi

# Configure SSH to use 1Password agent
mkdir -p ~/.ssh
if ! grep -q "1Password SSH Agent" ~/.ssh/config 2>/dev/null; then
    echo "Configuring SSH to use 1Password agent..."
    cat >> ~/.ssh/config << 'EOF'

# 1Password SSH Agent
Host *
    IdentityAgent ~/.1password/agent.sock
EOF
fi

# Configure git to use SSH for GitHub (this ensures git clones use SSH)
echo "Configuring git to use SSH for GitHub..."
git config --global url."git@github.com:".insteadOf "https://github.com/"

# Check if SSH agent is enabled
if [ ! -S ~/.1password/agent.sock ]; then
    echo "WARNING: 1Password SSH agent not detected"
    echo "Please enable it manually:"
    echo "1. Open 1Password desktop app"
    echo "2. Go to Settings → Developer"
    echo "3. Enable 'Use the SSH agent'"
    echo "4. Restart terminal for SSH_AUTH_SOCK to take effect"
else
    echo "1Password SSH agent detected and ready"
fi

echo "1Password CLI configuration complete"