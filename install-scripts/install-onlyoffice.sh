#!/bin/bash

set -e
source "$(dirname "$(dirname "$0")")/utils.sh"

init_logging "install-onlyoffice"

# Uninstall LibreOffice if present
packages_to_remove=()
if pacman -Q libreoffice-still &> /dev/null; then
    packages_to_remove+=("libreoffice-still")
fi
if pacman -Q libreoffice-fresh &> /dev/null; then
    packages_to_remove+=("libreoffice-fresh")
fi

if [ ${#packages_to_remove[@]} -gt 0 ]; then
    show_action "Uninstalling LibreOffice"
    log_command "sudo pacman -Runs --noconfirm ${packages_to_remove[*]}" \
        "libreoffice-removal" \
        "LibreOffice uninstalled" \
        "Failed to uninstall LibreOffice"
else
    show_skip "LibreOffice not installed"
fi

# Install ONLYOFFICE with GitHub fallback
show_action "Installing ONLYOFFICE"
install_package "onlyoffice-bin"

show_success "Office suite setup complete"