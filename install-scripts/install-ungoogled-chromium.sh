#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Remove standard chromium if installed
if pacman -Q chromium >/dev/null 2>&1; then
    echo "Removing standard chromium..."
    if sudo pacman -Rs --noconfirm chromium > ./logs/chromium-removal.log 2>&1; then
        echo "✓ Standard chromium removed"
    else
        echo "✗ Failed to remove standard chromium (see ./logs/chromium-removal.log)"
        exit 1
    fi
else
    echo "✓ Standard chromium not installed"
fi

# Keep zen browser - don't remove it
if pacman -Q zen-browser-bin >/dev/null 2>&1; then
    echo "✓ Zen browser found - keeping as default browser"
else
    echo "Installing zen browser as default..."
    if yay -S --noconfirm zen-browser-bin > ./logs/zen-browser.log 2>&1; then
        echo "✓ Zen browser installed"
    else
        echo "✗ Zen browser installation failed (see ./logs/zen-browser.log)"
        exit 1
    fi
fi

# Install ungoogled-chromium binary from chaotic-aur (no compilation needed)
mkdir -p ./logs
if ! pacman -Q ungoogled-chromium-bin >/dev/null 2>&1; then
    echo "Installing ungoogled-chromium-bin..."
    if yay -S --noconfirm chaotic-aur/ungoogled-chromium-bin > ./logs/ungoogled-chromium.log 2>&1; then
        echo "✓ Ungoogled-chromium-bin installed"
    else
        echo "✗ Ungoogled-chromium-bin installation failed (see ./logs/ungoogled-chromium.log)"
        exit 1
    fi
else
    echo "✓ Ungoogled-chromium-bin already installed"
fi

# Configure zen browser as default browser (keep it as default)
echo "Ensuring zen browser is set as default browser..."
if xdg-settings set default-web-browser zen-browser.desktop 2>/dev/null; then
    echo "✓ Zen browser set as default"
else
    echo "Warning: Could not set default browser (may need to set manually)"
fi

if xdg-mime default zen-browser.desktop x-scheme-handler/http 2>/dev/null && \
   xdg-mime default zen-browser.desktop x-scheme-handler/https 2>/dev/null; then
    echo "✓ Zen browser MIME associations set"
else
    echo "Warning: Could not set MIME associations (may need to set manually)"
fi

# Ensure omarchy-menu script uses zen browser
if [ -f "$HOME/.local/share/omarchy/bin/omarchy-menu" ]; then
    echo "Ensuring omarchy-menu uses zen browser..."
    sed -i 's/setsid chromium --new-window --app=/setsid zen-browser --new-window --app=/' "$HOME/.local/share/omarchy/bin/omarchy-menu"
    echo "✓ Omarchy-menu configured for zen browser"
fi

# Configure 1Password integration for both browsers
sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers
if ! sudo grep -q "chromium" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "chromium" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi
if ! sudo grep -q "zen-bin" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi
echo "✓ 1Password integration configured for both browsers"