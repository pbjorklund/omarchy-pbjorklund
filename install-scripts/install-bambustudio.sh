#!/bin/bash

# Install BambuStudio - 3D printer software for BambuLab printers
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_bambustudio() {
    install_package "bambustudio-bin" "" "bambustudio"
    
    # Fix AUR package permissions bug
    if [ -f "/usr/share/applications/BambuStudio.desktop" ]; then
        show_action "Fixing BambuStudio desktop file permissions"
        sudo chmod 644 /usr/share/applications/BambuStudio.desktop
        sudo update-desktop-database /usr/share/applications/
        show_success "Desktop file permissions fixed"
    fi
    
    if [ -f "/usr/bin/bambu-studio" ]; then
        show_action "Fixing BambuStudio binary permissions"
        sudo chmod 755 /usr/bin/bambu-studio
        show_success "Binary permissions fixed"
    fi
}

install_bambustudio