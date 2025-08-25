#!/bin/bash

set -e

# Remove fcitx5 autostart from omarchy default config
OMARCHY_AUTOSTART="$HOME/.local/share/omarchy/default/hypr/autostart.conf"

if [[ -f "$OMARCHY_AUTOSTART" ]]; then
    if grep -q "fcitx5" "$OMARCHY_AUTOSTART"; then
        echo "Removing fcitx5 autostart from omarchy default config..."
        sed -i '/fcitx5/d' "$OMARCHY_AUTOSTART"
        echo "✓ fcitx5 autostart removed from omarchy config"
    else
        echo "✓ fcitx5 autostart already removed from omarchy config"
    fi
else
    echo "✓ omarchy autostart config not found, nothing to remove"
fi