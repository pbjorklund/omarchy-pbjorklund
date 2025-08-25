#!/bin/bash

# Replace chromium with zen browser
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Keep chromium installed alongside zen browser

# Remove chromium desktop entry if it exists
if [ -f "applications/chromium.desktop" ]; then
    echo "Removing chromium desktop entry..."
    rm applications/chromium.desktop
fi

# Install zen browser from AUR with GitHub fallback
echo "Installing zen browser..."
install_package "zen-browser-bin"

# Configure zen browser as default browser
echo "Setting zen browser as default..."
if xdg-settings set default-web-browser zen-browser.desktop 2>/dev/null; then
    echo "Default browser set successfully"
else
    echo "Warning: Could not set default browser (may need to set manually)"
fi

if xdg-mime default zen-browser.desktop x-scheme-handler/http 2>/dev/null && \
   xdg-mime default zen-browser.desktop x-scheme-handler/https 2>/dev/null; then
    echo "MIME associations set successfully"
else
    echo "Warning: Could not set MIME associations (may need to set manually)"
fi

# Fix omarchy-menu script to use zen instead of chromium
if [ -f "$HOME/.local/share/omarchy/bin/omarchy-menu" ]; then
    echo "Updating omarchy-menu to use zen browser..."
    sed -i 's/setsid chromium --new-window --app=/setsid zen-browser --new-window --app=/' "$HOME/.local/share/omarchy/bin/omarchy-menu"
fi

# Configure 1Password integration
sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers
if ! sudo grep -q "zen-bin" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi