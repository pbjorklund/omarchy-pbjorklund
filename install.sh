#!/bin/bash

# Personal omarchy configuration script
# Applies custom overrides to an existing omarchy installation
set -e

catch_errors() {
  echo
  echo "Personal omarchy configuration failed!"
  echo "You can retry by running: bash install.sh"
}

trap catch_errors ERR

echo "Personal Omarchy Configuration"
echo

# Prerequisites check
if ! command -v pacman &> /dev/null; then
    echo "This script requires Arch Linux"
    exit 1
fi

if [ "$EUID" -eq 0 ]; then
    echo "Do not run this script as root"
    exit 1
fi

if [ ! -f "$HOME/.local/share/omarchy/install.sh" ]; then
    echo "Omarchy not found!"
    echo
    echo "Please install omarchy first:"
    echo "1. Download Arch Linux ISO and create bootable USB"
    echo "2. Follow installation instructions at https://omarchy.org"
    echo "3. Reboot into your omarchy system"
    echo "4. Then run this script to apply personal customizations"
    echo
    exit 1
fi

if ! command -v hyprctl &> /dev/null; then
    echo "Hyprland not found! Please ensure omarchy installation is complete."
    exit 1
fi

OVERRIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/overrides"

echo "Setting up development directories"
source "$OVERRIDES_DIR/setup-directories.sh"

echo "Installing AMD graphics drivers"
source "$OVERRIDES_DIR/install-amd-drivers.sh"

echo "Installing personal applications"
source "$OVERRIDES_DIR/install-obsidian.sh"
source "$OVERRIDES_DIR/install-zotero.sh"
source "$OVERRIDES_DIR/install-opencode.sh"
source "$OVERRIDES_DIR/install-claude-code.sh"

echo "Installing custom scripts"
source "$OVERRIDES_DIR/install-bin-scripts.sh"

echo "Applying personal dotfiles" 
source "$OVERRIDES_DIR/install-stow.sh"
source "$OVERRIDES_DIR/link-dotfiles.sh"

echo "Setting up desktop integration"
source "$OVERRIDES_DIR/copy-desktop-files.sh"
source "$OVERRIDES_DIR/set-theme-pbjorklund.sh"

echo
echo "Personal omarchy configuration complete!"
echo
echo "Management commands:"
echo "  Reset to omarchy defaults: omarchy-refresh-hyprland"
echo "  Compare configs: omarchy-compare-config ~/.config/hypr/bindings.conf"
echo "  Reapply configs: cd dotfiles-overrides && stow -t \$HOME ."