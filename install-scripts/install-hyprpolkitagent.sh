#!/bin/bash

set -e

source ./utils.sh

echo "Installing hyprpolkitagent..."

mkdir -p ./logs

# Install hyprpolkitagent
if ! command -v hyprpolkitagent &> /dev/null; then
    echo "Installing hyprpolkitagent..."
    if yay -S --noconfirm hyprpolkitagent > ./logs/hyprpolkitagent.log 2>&1; then
        echo "✓ hyprpolkitagent installed"
    else
        echo "✗ hyprpolkitagent installation failed (see ./logs/hyprpolkitagent.log)"
        return 1
    fi
else
    echo "✓ hyprpolkitagent already installed"
fi

# Kill any running polkit-gnome agents
if pgrep -f "polkit-gnome-authentication-agent" > /dev/null; then
    echo "Stopping polkit-gnome-authentication-agent..."
    pkill -f "polkit-gnome-authentication-agent" || true
    echo "✓ polkit-gnome-authentication-agent stopped"
fi

# Enable hyprpolkitagent service if systemd is available
if systemctl --user list-unit-files hyprpolkitagent.service &> /dev/null; then
    echo "Enabling hyprpolkitagent systemd service..."
    systemctl --user enable --now hyprpolkitagent.service
    echo "✓ hyprpolkitagent service enabled and started"
else
    echo "✓ hyprpolkitagent installed (will be started via Hyprland config)"
fi

echo "✓ hyprpolkitagent setup complete"