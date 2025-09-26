#!/bin/bash
set -e

# Source utils for package installation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

init_logging "swerty"

show_action "Installing Swerty keyboard layout"

# Check if already installed
if grep -q "swerty" /usr/share/X11/xkb/symbols/se 2>/dev/null; then
    show_skip "Swerty already installed"
    exit 0
fi

# Download Swerty if not present
if [ ! -f "swerty-linux.tar.gz" ]; then
    show_action "Downloading Swerty..."
    wget https://johanegustafsson.net/projects/swerty/swerty-linux.tar.gz > "$LOG_DIR/swerty-download.log" 2>&1
fi

# Extract if not present
if [ ! -d "swerty_linux" ]; then
    show_action "Extracting Swerty..."
    tar -xzf swerty-linux.tar.gz > "$LOG_DIR/swerty-extract.log" 2>&1
fi

# Backup original files
show_action "Backing up XKB configuration files..."
sudo cp /usr/share/X11/xkb/symbols/se /usr/share/X11/xkb/symbols/se.backup > ./logs/swerty-backup.log 2>&1
sudo cp /usr/share/X11/xkb/rules/evdev.xml /usr/share/X11/xkb/rules/evdev.xml.backup >> ./logs/swerty-backup.log 2>&1
sudo cp /usr/share/X11/xkb/rules/evdev.lst /usr/share/X11/xkb/rules/evdev.lst.backup >> ./logs/swerty-backup.log 2>&1

# Add Swerty layout to symbols file
show_action "Adding Swerty layout to symbols..."
sudo sh -c 'cat swerty_linux/se.txt >> /usr/share/X11/xkb/symbols/se' > ./logs/swerty-symbols.log 2>&1

# Add variant to evdev.xml
show_action "Adding Swerty variant to evdev.xml..."
sudo sed -i '/<name>se<\/name>/,/<variantList>/{ /<variantList>/a\        <variant>\n          <configItem>\n            <name>swerty</name>\n            <description>Swerty</description>\n          </configItem>\n        </variant>
}' /usr/share/X11/xkb/rules/evdev.xml > ./logs/swerty-evdev-xml.log 2>&1

# Add variant to evdev.lst
show_action "Adding Swerty variant to evdev.lst..."
sudo sed -i '/! variant/a\  swerty          se: Swerty' /usr/share/X11/xkb/rules/evdev.lst > ./logs/swerty-evdev-lst.log 2>&1

show_success "Swerty keyboard layout installed"
echo "  Use 'kb_layout = se,us' and 'kb_variant = swerty,' in Hyprland"
echo "  Swedish characters (åäö) accessible via AltGr on ;, ', [ keys"