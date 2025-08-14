#!/bin/bash
# Smart wallpaper cycling script for Hyprland - dynamically finds monitors by description
# Usage: cycle-wallpaper.sh <main|secondary|laptop>

WALLPAPER_DIR="$HOME/.local/share/wallpapers"

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
    MONITOR=$(find_monitor_connector "$TARGET_DESC")
    WALLPAPERS=($(find -L "$WALLPAPER_DIR" \( -name 'laptop*' -o -name 'main*' \) -type f | grep -E '\.(jpg|webp|png)$' | sort))
    ;;
main)
    TARGET_DESC=$(determine_main_monitor)
    MONITOR=$(find_monitor_connector "$TARGET_DESC")
    # Choose wallpapers based on monitor type
    if [[ "$TARGET_DESC" == "Samsung Electric Company SE790C HTRH401237" ]]; then
        WALLPAPERS=($(find -L "$WALLPAPER_DIR" \( -name 'ultra*' -o -name 'main*' \) -type f | grep -E '\.(jpg|webp|png)$' | sort))
    else
        WALLPAPERS=($(find -L "$WALLPAPER_DIR" \( -name 'main*' -o -name 'work*' \) -type f | grep -E '\.(jpg|webp|png)$' | sort))
    fi
    ;;
secondary)
    TARGET_DESC=$(determine_secondary_monitor)
    if [[ -z "$TARGET_DESC" ]]; then
        echo "No secondary monitor available in current setup"
        exit 1
    fi
    MONITOR=$(find_monitor_connector "$TARGET_DESC")
    # Choose wallpapers based on monitor type
    if [[ "$TARGET_DESC" == "Acer Technologies XV240Y P 0x944166C5" ]]; then
        WALLPAPERS=($(find -L "$WALLPAPER_DIR" -name 'portrait*' -type f | grep -E '\.(jpg|webp|png)$' | sort))
    else
        WALLPAPERS=($(find -L "$WALLPAPER_DIR" -name 'main*' -type f | grep -E '\.(jpg|webp|png)$' | sort))
    fi
    ;;
*)
    echo "Usage: $0 <main|secondary|laptop>"
    echo "  main      - Smart main monitor detection"
    echo "  secondary - Smart secondary monitor detection"
    echo "  laptop    - BOE laptop display"
    exit 1
    ;;
esac

if [[ -z "$MONITOR" ]]; then
    echo "Monitor not found for type: $1"
    exit 1
fi

if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
    echo "No wallpapers found for monitor type: $1"
    exit 1
fi

# Kill existing swaybg for this monitor
pkill -f "swaybg.*$MONITOR" 2>/dev/null || true

# Select random wallpaper
WALLPAPER="${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}"

# Apply wallpaper using the dynamically found connector name
swaybg -o "$MONITOR" -i "$WALLPAPER" -m fill &

echo "Applied wallpaper: $(basename "$WALLPAPER") to $MONITOR ($1 monitor)"
