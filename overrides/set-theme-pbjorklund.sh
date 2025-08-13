#!/bin/bash

# Set pbjorklund omarchy theme and apply smart wallpapers
# This integrates our custom theming with omarchy's theme system

set -e

# Set the pbjorklund theme as current
mkdir -p ~/.config/omarchy/current
ln -snf ~/.config/omarchy/themes/pbjorklund ~/.config/omarchy/current/theme

# Apply smart wallpaper logic from our custom script
# This maintains our monitor-specific wallpaper intelligence
if [ -x "$HOME/.local/bin/hypr-scripts/init-wallpapers.sh" ]; then
    # Update the wallpaper script to use theme backgrounds
    THEME_WALLPAPER_DIR="$HOME/.config/omarchy/current/theme/backgrounds"
    
    # Export for the wallpaper script to use
    export WALLPAPER_DIR="$THEME_WALLPAPER_DIR"
    
    # Run our smart wallpaper initialization
    "$HOME/.local/bin/hypr-scripts/init-wallpapers.sh" 2>/dev/null || true
fi