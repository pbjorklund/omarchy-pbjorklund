#!/bin/bash
set -e
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Initialize logging if not already done (when running standalone)
if [ -z "$LOG_DIR" ]; then
    init_logging "intel-vaapi"
fi

install_intel_vaapi() {
    mkdir -p "$LOG_DIR"
    
    show_action "Installing Intel VAAPI drivers for screen recording"
    
    # Check if packages are already installed
    if pacman -Q libva-utils intel-media-driver &>/dev/null; then
        show_success "Intel VAAPI drivers already installed"
        return 0
    fi
    
    # Install Intel VAAPI utilities
    if ! yay -Q libva-utils &>/dev/null; then
        show_action "Installing Intel VAAPI utilities"
        if yay -S --noconfirm libva-utils > "$LOG_DIR/libva-utils.log" 2>&1; then
            show_success "Intel VAAPI utilities installed"
        else
            show_error "Intel VAAPI utilities installation failed (see $LOG_DIR/libva-utils.log)"
            return 1
        fi
    else
        show_success "Intel VAAPI utilities already installed"
    fi
    
    # Install Intel media driver
    if ! yay -Q intel-media-driver &>/dev/null; then
        show_action "Installing Intel media driver"
        if yay -S --noconfirm intel-media-driver > "$LOG_DIR/intel-media-driver.log" 2>&1; then
            show_success "Intel media driver installed"
        else
            show_error "Intel media driver installation failed (see $LOG_DIR/intel-media-driver.log)"
            return 1
        fi
    else
        show_success "Intel media driver already installed"
    fi
    
    show_success "Intel VAAPI drivers installation complete"
}

main() {
    install_intel_vaapi
}

main "$@"