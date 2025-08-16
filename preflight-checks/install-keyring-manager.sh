#!/bin/bash
set -e

# Install keyring manager
echo "Installing keyring manager..."

if command -v seahorse &> /dev/null; then
    echo "✓ Keyring manager already installed"
else
    echo "Installing seahorse keyring manager..."
    log_command "yay -S --noconfirm seahorse" "seahorse-install" "Keyring manager installed" "Keyring manager installation failed"
fi