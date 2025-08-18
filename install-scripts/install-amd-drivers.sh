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
    
    # Install AMD graphics drivers (skip lib32 packages if there are conflicts)
    show_action "Installing main AMD packages"
    if yay -S --noconfirm --needed mesa xf86-video-amdgpu vulkan-radeon > "$LOG_DIR/amd-main.log" 2>&1; then
        show_success "Main AMD packages installed"
    else
        show_error "Failed to install main AMD graphics packages (see $LOG_DIR/amd-main.log)"
        return 1
    fi
    
    show_action "Installing 32-bit AMD packages"
    if yay -S --noconfirm --needed lib32-mesa lib32-vulkan-radeon > "$LOG_DIR/amd-lib32.log" 2>&1; then
        show_success "32-bit AMD packages installed"
    else
        show_skip "Could not install 32-bit packages due to conflicts (32-bit applications may not work correctly)"
    fi
    
    # Install AMD utilities
    show_action "Installing AMD utilities"
    if yay -S --noconfirm --needed radeontop > "$LOG_DIR/amd-utils.log" 2>&1; then
        show_success "AMD utilities installed"
    else
        show_error "Failed to install radeontop (see $LOG_DIR/amd-utils.log)"
        return 1
    fi
    
    show_success "AMD graphics drivers installation completed"
}

main() {
    install_amd_drivers
}

main "$@"