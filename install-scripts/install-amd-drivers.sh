#!/bin/bash

# Install AMD Radeon drivers for RX 9700 XT
set -e
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Initialize logging if not already done (when running standalone)
if [ -z "$LOG_DIR" ]; then
    init_logging "amd-drivers"
fi

install_amd_drivers() {
    mkdir -p "$LOG_DIR"
    
    # Check if AMD GPU is present
    if ! lspci | grep -E '(VGA|Display|3D).*AMD|Advanced Micro Devices' >/dev/null 2>&1; then
        show_skip "No AMD GPU detected, skipping AMD driver installation"
        return 0
    fi
    
    show_action "AMD GPU detected - checking driver installation"
    
    # Check if AMD drivers are already properly installed
    if pacman -Q mesa xf86-video-amdgpu vulkan-radeon radeontop >/dev/null 2>&1; then
        show_success "AMD drivers already installed"
        return 0
    fi
    
    # Install AMD graphics drivers
    show_action "Installing main AMD packages"
    install_package "mesa"
    install_package "xf86-video-amdgpu"  
    install_package "vulkan-radeon"
    
    show_action "Installing 32-bit AMD packages"
    install_package "lib32-mesa"
    install_package "lib32-vulkan-radeon"
    
    # Install AMD utilities
    show_action "Installing AMD utilities"
    install_package "radeontop"
    

    
    show_success "AMD graphics drivers installation completed"
}

main() {
    install_amd_drivers
}

main "$@"