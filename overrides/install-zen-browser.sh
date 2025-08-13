#!/bin/bash

# Replace chromium with zen browser
set -e

# Remove chromium if installed
sudo pacman -Rs --noconfirm chromium || true

# Install zen browser from AUR
yay -S --noconfirm zen-browser-bin

# Configure zen browser as default browser
xdg-settings set default-web-browser zen-browser.desktop
xdg-mime default zen-browser.desktop x-scheme-handler/http
xdg-mime default zen-browser.desktop x-scheme-handler/https