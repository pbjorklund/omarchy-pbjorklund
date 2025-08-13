#!/bin/bash
# Dynamic wallpaper initialization script for Hyprland
# Sets default wallpapers on all monitors using smart detection
#
# Smart Monitor Detection:
# - When SE790C (Samsung ultrawide) is connected: it becomes main (single monitor setup)
# - When XZ321QU (Acer) is connected: XZ321QU=main, XV240Y=secondary (home office setup)
# - When F3T3KS2 (Dell) is connected: F3T3KS2=main, S24F350=secondary (wife's setup)
# - laptop always refers to BOE 0x094C (built-in laptop screen)
#
# Technical Notes:
# - Uses monitor descriptions for stable identification across sessions
# - Monitor IDs can change but descriptions remain constant
# - Script dynamically finds current connector names from descriptions
# - Gracefully handles disconnected monitors by checking if connector exists

# Wallpaper directory - defaults to theme backgrounds, fallback to local wallpapers
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/.config/omarchy/current/theme/backgrounds}"
if [ ! -d "$WALLPAPER_DIR" ]; then
    WALLPAPER_DIR="$HOME/.local/share/wallpapers"
fi

# Function to find current connector name by monitor description
find_monitor_connector() {
    local target_desc="$1"
    hyprctl monitors -j | jq -r ".[] | select(.description == \"$target_desc\") | .name"
}

# Function to determine which monitor should be main based on what's connected
determine_main_monitor() {
    # Check for Samsung ultrawide (work setup)
    local samsung_connector=$(find_monitor_connector "Samsung Electric Company SE790C HTRH401237")
    if [[ -n "$samsung_connector" ]]; then
        echo "Samsung Electric Company SE790C HTRH401237"
        return
    fi

    # Check for Acer XZ321QU (home office main)
    local acer_connector=$(find_monitor_connector "Acer Technologies Acer XZ321QU 0x9372982E")
    if [[ -n "$acer_connector" ]]; then
        echo "Acer Technologies Acer XZ321QU 0x9372982E"
        return
    fi

    # Check for Dell (wife's setup main)
    local dell_connector=$(find_monitor_connector "Dell Inc. DELL U2419HC F3T3KS2")
    if [[ -n "$dell_connector" ]]; then
        echo "Dell Inc. DELL U2419HC F3T3KS2"
        return
    fi

    # Fallback to laptop if no external monitors
    echo "BOE 0x094C"
}

# Function to determine which monitor should be secondary based on what's connected
determine_secondary_monitor() {
    # Check for home office secondary (portrait)
    local acer_portrait_connector=$(find_monitor_connector "Acer Technologies XV240Y P 0x944166C5")
    if [[ -n "$acer_portrait_connector" ]]; then
        echo "Acer Technologies XV240Y P 0x944166C5"
        return
    fi

    # Check for wife's setup secondary
    local samsung_secondary_connector=$(find_monitor_connector "Samsung Electric Company S24F350 H4ZNA00867")
    if [[ -n "$samsung_secondary_connector" ]]; then
        echo "Samsung Electric Company S24F350 H4ZNA00867"
        return
    fi

    # No secondary monitor available
    echo ""
}

# Kill any existing swaybg processes
pkill swaybg 2>/dev/null || true

# Wait a moment for processes to clean up
sleep 0.5

# Set wallpaper for main monitor (smart detection)
MAIN_DESC=$(determine_main_monitor)
MAIN_MONITOR=$(find_monitor_connector "$MAIN_DESC")
if [[ -n "$MAIN_MONITOR" ]]; then
    if [[ "$MAIN_DESC" == "Samsung Electric Company SE790C HTRH401237" ]]; then
        swaybg -o "$MAIN_MONITOR" -i "$WALLPAPER_DIR/ultra.png" -m fill &
        echo "Set ultra-wide wallpaper on $MAIN_MONITOR"
    else
        swaybg -o "$MAIN_MONITOR" -i "$WALLPAPER_DIR/main.png" -m fill &
        echo "Set main wallpaper on $MAIN_MONITOR"
    fi
fi

# Set wallpaper for secondary monitor (smart detection)
SECONDARY_DESC=$(determine_secondary_monitor)
if [[ -n "$SECONDARY_DESC" ]]; then
    SECONDARY_MONITOR=$(find_monitor_connector "$SECONDARY_DESC")
    if [[ -n "$SECONDARY_MONITOR" ]]; then
        if [[ "$SECONDARY_DESC" == "Acer Technologies XV240Y P 0x944166C5" ]]; then
            swaybg -o "$SECONDARY_MONITOR" -i "$WALLPAPER_DIR/portrait2.jpg" -m fill &
            echo "Set portrait wallpaper on $SECONDARY_MONITOR"
        else
            swaybg -o "$SECONDARY_MONITOR" -i "$WALLPAPER_DIR/main.png" -m fill &
            echo "Set secondary wallpaper on $SECONDARY_MONITOR"
        fi
    fi
fi

# Set wallpaper for laptop monitor (if connected)
LAPTOP_DESC="BOE 0x094C"
LAPTOP_MONITOR=$(find_monitor_connector "$LAPTOP_DESC")
if [[ -n "$LAPTOP_MONITOR" ]]; then
    swaybg -o "$LAPTOP_MONITOR" -i "$WALLPAPER_DIR/main.png" -m fill &
    echo "Set laptop wallpaper on $LAPTOP_MONITOR"
fi

echo "Wallpaper initialization complete"
