#!/bin/bash

set -e

source ./utils.sh

echo "Removing GNOME polkit agent..."

mkdir -p ./logs

# Stop any running polkit-gnome agents
if pgrep -f "polkit-gnome-authentication-agent" > /dev/null; then
    echo "Stopping polkit-gnome-authentication-agent..."
    pkill -f "polkit-gnome-authentication-agent" || true
    echo "✓ polkit-gnome-authentication-agent stopped"
fi

# Remove polkit-gnome package if installed
if pacman -Qq polkit-gnome &> /dev/null; then
    echo "Removing polkit-gnome package..."
    if sudo pacman -Rns --noconfirm polkit-gnome > ./logs/polkit-gnome-removal.log 2>&1; then
        echo "✓ polkit-gnome package removed"
    else
        echo "✗ polkit-gnome removal failed (see ./logs/polkit-gnome-removal.log)"
        return 1
    fi
else
    echo "✓ polkit-gnome package not installed"
fi

# Remove any autostart entries
if [ -f "$HOME/.config/autostart/polkit-gnome-authentication-agent-1.desktop" ]; then
    rm -f "$HOME/.config/autostart/polkit-gnome-authentication-agent-1.desktop"
    echo "✓ Removed polkit-gnome autostart entry"
fi

# Disable any omarchy polkit-gnome service if it exists
if systemctl --user list-unit-files | grep -q "polkit-gnome"; then
    echo "Disabling polkit-gnome systemd service..."
    systemctl --user disable polkit-gnome.service 2>/dev/null || true
    systemctl --user stop polkit-gnome.service 2>/dev/null || true
    echo "✓ polkit-gnome systemd service disabled"
fi

echo "✓ GNOME polkit agent removal complete"