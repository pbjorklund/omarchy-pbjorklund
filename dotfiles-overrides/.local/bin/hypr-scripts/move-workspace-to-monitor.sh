#!/bin/bash
# Move workspace to monitor by stable identifier - dynamically finds monitor name
# Usage: move-workspace-to-monitor.sh <main|secondary|laptop>
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
# - Script gracefully handles disconnected monitors and different setups

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

case "$1" in
laptop)
    TARGET_DESC="BOE 0x094C"
    ;;
main)
    TARGET_DESC=$(determine_main_monitor)
    ;;
secondary)
    TARGET_DESC=$(determine_secondary_monitor)
    if [[ -z "$TARGET_DESC" ]]; then
        echo "No secondary monitor available in current setup"
        exit 1
    fi
    ;;
*)
    echo "Usage: $0 <main|secondary|laptop>"
    exit 1
    ;;
esac

# Find the current monitor name (connector) for this description
MONITOR_NAME=$(find_monitor_connector "$TARGET_DESC")

if [[ -z "$MONITOR_NAME" ]]; then
    echo "Monitor with description '$TARGET_DESC' not found"
    exit 1
fi

echo "Moving workspace to $1 monitor ($MONITOR_NAME)"

# Move current workspace to the found monitor using the monitor name
hyprctl dispatch movecurrentworkspacetomonitor "$MONITOR_NAME"
