#!/bin/bash

# Install and configure chromium browser
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

echo "Installing chromium..."
install_package "chromium"

# Configure 1Password integration
sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers
if ! sudo grep -q "chromium" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "chromium" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi

echo "✓ Chromium installation complete"
echo "Note: Install 1Password extension manually from Chrome Web Store"