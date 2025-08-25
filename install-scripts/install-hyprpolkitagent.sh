#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_package "hyprpolkitagent"

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