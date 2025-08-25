#!/bin/bash

set -e
source "$(dirname "$(dirname "$0")")/utils.sh"

init_logging "install-teams-for-linux"

# Install Teams for Linux v2.3.0 using the electron-bin package
# Clean up old versions first
if pacman -Q teams-for-linux &> /dev/null; then
    sudo pacman -Runs --noconfirm teams-for-linux 2>/dev/null || true
fi
if pacman -Q teams-for-linux-bin &> /dev/null; then
    sudo pacman -Runs --noconfirm teams-for-linux-bin 2>/dev/null || true
fi

# Install Teams for Linux v2.3.0 with GitHub fallback
install_package "teams-for-linux-electron-bin" "IsmaelMartinez/teams-for-linux" "teams-for-linux-electron" "release"

show_success "Teams for Linux setup complete"