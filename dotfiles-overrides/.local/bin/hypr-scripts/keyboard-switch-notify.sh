#!/bin/bash

# Switch to next keyboard layout
hyprctl switchxkblayout current next

# Small delay to ensure the layout change is registered
sleep 0.1

# Get current keyboard layout from the main keyboard
current_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap // empty')

# Fallback to any keyboard if no main keyboard found
if [ -z "$current_layout" ] || [ "$current_layout" = "null" ]; then
    current_layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.layout != "") | .active_keymap // "unknown"' | head -n1)
fi

# Map layout codes to friendly names
case "$current_layout" in
    "English (US)")
        layout_name="🇺🇸 English (US)"
        ;;
    "Swedish")
        layout_name="🇸🇪 Swedish"
        ;;
    "us")
        layout_name="🇺🇸 English (US)"
        ;;
    "se")
        layout_name="🇸🇪 Swedish"
        ;;
    *)
        layout_name="$current_layout"
        ;;
esac

# Kill any existing keyboard layout notifications
pkill -f "notify-send.*English\|notify-send.*Swedish" 2>/dev/null || true

# Send notification
notify-send "$layout_name" --icon=input-keyboard --expire-time=500