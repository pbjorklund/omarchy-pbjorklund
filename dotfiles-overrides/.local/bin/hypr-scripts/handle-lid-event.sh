#!/bin/bash
set -e

# Handle lid events intelligently based on docked status
# - When external monitors connected: disable laptop display (clamshell mode)
# - When no external monitors: suspend system

ACTION="$1"  # "close" or "open"

# Count external monitors (excluding laptop display eDP-1)
EXTERNAL_MONITORS=$(hyprctl monitors -j | jq '[.[] | select(.name != "eDP-1")] | length')

if [ "$ACTION" = "close" ]; then
    if [ "$EXTERNAL_MONITORS" -gt 0 ]; then
        # Docked mode: just disable laptop display
        hyprctl keyword monitor "eDP-1, disable"
        echo "Lid closed - disabled laptop display (docked mode)"
    else
        # Not docked: disable display and suspend
        hyprctl keyword monitor "eDP-1, disable"
        echo "Lid closed - suspending system (not docked)"
        systemctl suspend
    fi
elif [ "$ACTION" = "open" ]; then
    # Always re-enable laptop display when lid opens
    hyprctl keyword monitor "eDP-1, preferred, auto, auto"
    echo "Lid opened - enabled laptop display"
fi