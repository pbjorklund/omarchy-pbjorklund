#!/bin/bash
set -e

# DisplayLink Driver Installation for Laptop Multi-Monitor Setups
# 
# WHAT IS DISPLAYLINK?
# DisplayLink is a technology that enables additional monitors via USB connections.
# It creates virtual displays using the EVDI (Extensible Virtual Display Interface) kernel driver.
#
# WHY DO WE NEED IT?
# - Laptops have limited native display outputs (typically 1-2 HDMI/DP ports)
# - USB-C docks often use DisplayLink chips to provide more monitor connections
# - Without DisplayLink drivers, extra monitors connected via USB won't work
# 
# WHEN IS IT NEEDED?
# - Wife's office: Dell+Samsung setup via USB-C dock with DisplayLink chip
# - Home office: 2x Acer setup uses native DP/HDMI (no DisplayLink needed)
# - Work office: 34" monitor likely uses native connection
#
# HOW IT WORKS:
# 1. EVDI kernel module creates virtual display devices (/dev/dri/cardX)
# 2. DisplayLink userspace driver manages USB communication with dock
# 3. Xorg modesetting driver renders to these virtual displays
# 4. Content is compressed and sent via USB to the dock's DisplayLink chip
#
# COMPONENTS INSTALLED:
# - evdi-dkms: Kernel module for virtual display creation
# - displaylink: Userspace driver for USB communication
# - displaylink.service: SystemD service for automatic startup
# - Xorg config: /etc/X11/xorg.conf.d/20-evdi.conf for proper rendering
#
# REFERENCES:
# - Arch Wiki: https://wiki.archlinux.org/title/DisplayLink
# - EVDI GitHub: https://github.com/DisplayLink/evdi
# - DisplayLink support: https://support.displaylink.com/
#
# NOTE: Desktop systems don't need DisplayLink as they have sufficient native outputs

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Initialize logging if not already done (when running standalone)
if [ -z "$LOG_DIR" ]; then
    init_logging "displaylink"
fi

# Check if we're on a laptop (has battery)
is_laptop() {
    [ -d "/sys/class/power_supply" ] && ls /sys/class/power_supply/ | grep -q "BAT"
}

install_displaylink_drivers() {
    mkdir -p "$LOG_DIR"
    
    if ! is_laptop; then
        show_skip "Desktop system detected - DisplayLink drivers not needed"
        return 0
    fi
    
    show_action "Installing DisplayLink drivers for laptop"
    
    # Install kernel headers (required for DKMS module compilation)
    if ! yay -Q linux-headers &>/dev/null; then
        show_action "Installing kernel headers for DKMS compilation"
        if yay -S --noconfirm linux-headers > "$LOG_DIR/kernel-headers.log" 2>&1; then
            show_success "Kernel headers installed"
        else
            show_error "Kernel headers installation failed (see $LOG_DIR/kernel-headers.log)"
            return 1
        fi
    else
        show_success "Kernel headers already installed"
    fi
    
    # Install EVDI kernel module (DKMS version)
    if ! yay -Q evdi-dkms &>/dev/null; then
        show_action "Installing evdi-dkms kernel module"
        if yay -S --noconfirm evdi-dkms > "$LOG_DIR/evdi-install.log" 2>&1; then
            show_success "EVDI kernel module installed"
        else
            show_error "EVDI installation failed (see $LOG_DIR/evdi-install.log)"
            return 1
        fi
    else
        show_success "EVDI kernel module already installed"
    fi
    
    # Install DisplayLink driver
    if ! yay -Q displaylink &>/dev/null; then
        show_action "Installing DisplayLink driver"
        if yay -S --noconfirm displaylink > "$LOG_DIR/displaylink-install.log" 2>&1; then
            show_success "DisplayLink driver installed"
        else
            show_error "DisplayLink driver installation failed (see $LOG_DIR/displaylink-install.log)"
            return 1
        fi
    else
        show_success "DisplayLink driver already installed"
    fi
    
    # Enable DisplayLink service
    if ! systemctl is-enabled displaylink.service &>/dev/null; then
        show_action "Enabling DisplayLink service"
        if sudo systemctl enable displaylink.service > "$LOG_DIR/displaylink-service.log" 2>&1; then
            show_success "DisplayLink service enabled"
        else
            show_error "Failed to enable DisplayLink service (see $LOG_DIR/displaylink-service.log)"
            return 1
        fi
    else
        show_success "DisplayLink service already enabled"
    fi
    
    # Create Xorg config for EVDI
    local xorg_config="/etc/X11/xorg.conf.d/20-evdi.conf"
    if [ ! -f "$xorg_config" ]; then
        show_action "Creating Xorg EVDI configuration"
        sudo tee "$xorg_config" > /dev/null <<'EOF'
Section "OutputClass"
	Identifier "DisplayLink"
	MatchDriver "evdi"
	Driver "modesetting"
	Option "AccelMethod" "none"
EndSection
EOF
        show_success "Xorg EVDI configuration created"
    else
        show_success "Xorg EVDI configuration already exists"
    fi
    
    show_success "DisplayLink setup complete - reboot required for full functionality"
}

main() {
    install_displaylink_drivers
}

main "$@"