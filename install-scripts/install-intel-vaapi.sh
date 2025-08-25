#!/bin/bash
set -e
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Initialize logging if not already done (when running standalone)
if [ -z "$LOG_DIR" ]; then
    init_logging "intel-vaapi"
fi

install_intel_vaapi() {
    show_action "Installing Intel VAAPI drivers for screen recording"
    
    # Check if packages are already installed
    if pacman -Q libva-utils intel-media-driver &>/dev/null; then
        show_success "Intel VAAPI drivers already installed"
        return 0
    fi
    
    # Install Intel VAAPI utilities
    install_package "libva-utils"
    
    # Install Intel media driver
    install_package "intel-media-driver"
    
    show_success "Intel VAAPI drivers installation complete"
}

main() {
    install_intel_vaapi
}

main "$@"