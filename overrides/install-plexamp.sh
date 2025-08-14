#!/bin/bash

# Install Plexamp music client for Plex
set -e

# Install plexamp from AUR (skip if already installed)
if ! pacman -Q plexamp-appimage >/dev/null 2>&1; then
    echo "Installing Plexamp..."
    yay -S --noconfirm plexamp-appimage
else
    echo "Plexamp already installed"
fi