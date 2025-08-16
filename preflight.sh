#!/bin/bash
set -e

echo "=== Omarchy Desktop Preflight Setup ==="
echo "Setting up prerequisites for installation"
echo

# Check requirements
if ! command -v pacman &> /dev/null; then
    echo "Error: This script requires Arch Linux"
    exit 1
fi

if ! command -v yay &> /dev/null; then
    echo "Error: yay (AUR helper) not found"
    echo "Omarchy should have installed yay during setup"
    exit 1
fi

# Setup passwordless sudo
echo "Setting up passwordless sudo..."
if ! sudo -n true 2>/dev/null; then
    echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$(whoami)" > /dev/null
    echo "✅ Passwordless sudo configured"
else
    echo "✅ Passwordless sudo already configured"
fi

# Install and setup keyring
if ! command -v seahorse &> /dev/null; then
    echo "Installing keyring tools..."
    yay -S --noconfirm seahorse < /dev/null
else
    echo "✅ Seahorse already installed"
fi

echo "Starting keyring daemon..."
if ! pgrep -x gnome-keyring-d >/dev/null; then
    eval $(gnome-keyring-daemon --start --components=secrets,ssh)
fi

# Check for existing keyring or prompt to create one
if [ ! -d "$HOME/.local/share/keyrings" ] || [ -z "$(ls -A "$HOME/.local/share/keyrings" 2>/dev/null)" ]; then
    echo
    echo "=== Keyring Setup Required ==="
    echo "Opening Seahorse to create your keyring:"
    echo "1. Right-click in the main area"
    echo "2. Select 'New' > 'Password Keyring'"
    echo "3. Name it 'Default' and set a password"
    echo "4. Right-click the new keyring and 'Set as Default'"
    echo "5. Close Seahorse when done"
    echo
    read -p "Press Enter to open Seahorse..."
    
    seahorse &
    wait $! 2>/dev/null || true
fi

# Check 1Password SSH agent
if [ -n "$SSH_AUTH_SOCK" ] && [[ "$SSH_AUTH_SOCK" == *"1password"* ]]; then
    echo "✅ 1Password SSH agent active"
elif [ -S "$HOME/.1password/agent.sock" ]; then
    echo "✅ 1Password SSH agent found"
else
    echo "❌ 1Password SSH agent not configured"
    echo "Please enable SSH agent in 1Password Settings → Developer"
    exit 1
fi

# Mark completion
touch "$HOME/.omarchy-preflight-complete"

echo
echo "=== Preflight Complete ==="
echo "✅ Prerequisites ready"
echo "✅ Run install.sh to continue"