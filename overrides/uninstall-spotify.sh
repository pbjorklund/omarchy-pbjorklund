#!/bin/bash

# Uninstall Spotify music streaming client
set -e

# Remove spotify if installed via AUR
if pacman -Q spotify >/dev/null 2>&1; then
    echo "Removing Spotify..."
    yay -Rs --noconfirm spotify >/dev/null 2>&1
else
    echo "Spotify not installed via AUR"
fi

# Remove spotify-launcher if installed
if pacman -Q spotify-launcher >/dev/null 2>&1; then
    echo "Removing Spotify launcher..."
    yay -Rs --noconfirm spotify-launcher >/dev/null 2>&1
else
    echo "Spotify launcher not installed"
fi

# Remove flatpak version if installed
if command -v flatpak >/dev/null 2>&1 && flatpak list | grep -q "com.spotify.Client" 2>/dev/null; then
    echo "Removing Spotify flatpak..."
    flatpak uninstall --assumeyes com.spotify.Client >/dev/null 2>&1
else
    echo "Spotify flatpak not installed"
fi

# Clean up user configuration and cache
if [ -d "$HOME/.config/spotify" ]; then
    echo "Removing Spotify configuration..."
    rm -rf "$HOME/.config/spotify"
fi

if [ -d "$HOME/.cache/spotify" ]; then
    echo "Removing Spotify cache..."
    rm -rf "$HOME/.cache/spotify"
fi

echo "Spotify uninstallation complete"