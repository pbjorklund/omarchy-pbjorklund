#!/bin/bash

# Replace chromium with zen browser
set -e

# Remove chromium if installed
if pacman -Q chromium >/dev/null 2>&1; then
    echo "Removing chromium..."
    sudo pacman -Rs --noconfirm chromium
else
    echo "Chromium not installed, skipping removal"
fi

# Install zen browser from AUR (skip if already installed)
if ! pacman -Q zen-browser-bin >/dev/null 2>&1; then
    echo "Installing zen browser..."
    yay -S --noconfirm zen-browser-bin
else
    echo "Zen browser already installed"
fi

# Configure zen browser as default browser
xdg-settings set default-web-browser zen-browser.desktop
xdg-mime default zen-browser.desktop x-scheme-handler/http
xdg-mime default zen-browser.desktop x-scheme-handler/https

# Configure 1Password integration
sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers
if ! sudo grep -q "zen-bin" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi