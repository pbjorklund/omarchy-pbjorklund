#!/bin/bash

# Uninstall Typora markdown editor
set -e

# Remove typora if installed via AUR
if pacman -Q typora >/dev/null 2>&1; then
    echo "Removing Typora..."
    yay -Rs --noconfirm typora >/dev/null 2>&1
else
    echo "Typora not installed via AUR"
fi

# Remove typora if installed via pacman
if pacman -Q typora-bin >/dev/null 2>&1; then
    echo "Removing Typora (bin)..."
    yay -Rs --noconfirm typora-bin >/dev/null 2>&1
else
    echo "Typora (bin) not installed"
fi

# Remove flatpak version if installed
if command -v flatpak >/dev/null 2>&1 && flatpak list | grep -q "io.typora.Typora" 2>/dev/null; then
    echo "Removing Typora flatpak..."
    flatpak uninstall --assumeyes io.typora.Typora >/dev/null 2>&1
else
    echo "Typora flatpak not installed"
fi

# Clean up user configuration
if [ -d "$HOME/.config/Typora" ]; then
    echo "Removing Typora configuration..."
    rm -rf "$HOME/.config/Typora"
fi

echo "Typora uninstallation complete"