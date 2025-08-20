#!/bin/bash
set -e

source "$(dirname "$0")/../utils.sh"
init_logging "setup-wake-on-lan"

INTERFACE="eno1"  # Your main ethernet interface

# Install package function
install_package() {
    local package="$1"
    if ! command -v "$package" &> /dev/null; then
        show_action "Installing $package"
        mkdir -p ./logs
        if yay -S --noconfirm "$package" > ./logs/"$package".log 2>&1; then
            show_success "$package installed"
        else
            show_error "$package installation failed (see ./logs/$package.log)"
            return 1
        fi
    else
        show_success "$package already installed"
    fi
}

setup_wake_on_lan() {
    show_action "Installing ethtool for Wake-on-LAN configuration"
    install_package ethtool
    
    show_action "Checking current Wake-on-LAN status"
    echo "Current WoL status for $INTERFACE:"
    sudo ethtool "$INTERFACE" | grep -i wake || echo "Wake-on-LAN info not available"
    
    show_action "Enabling Wake-on-LAN on $INTERFACE"
    if sudo ethtool -s "$INTERFACE" wol g; then
        show_success "Wake-on-LAN enabled on $INTERFACE"
    else
        show_error "Failed to enable Wake-on-LAN on $INTERFACE"
        return 1
    fi
    
    show_action "Creating systemd service for persistent WoL"
    sudo tee /etc/systemd/system/wol@.service > /dev/null << 'EOF'
[Unit]
Description=Wake-on-LAN for %i
Requires=network.target
After=network.target

[Service]
ExecStart=/usr/bin/ethtool -s %i wol g
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

    show_action "Enabling WoL service for $INTERFACE"
    sudo systemctl daemon-reload
    sudo systemctl enable "wol@$INTERFACE.service"
    sudo systemctl start "wol@$INTERFACE.service"
    
    show_action "Verifying Wake-on-LAN configuration"
    echo "Final WoL status:"
    sudo ethtool "$INTERFACE" | grep -i wake
    
    show_success "Wake-on-LAN setup complete"
    echo
    echo "To test WoL from another machine, use:"
    echo "  wakeonlan $(cat /sys/class/net/$INTERFACE/address)"
    echo "  (Install wakeonlan package on the sending machine)"
}

setup_wake_on_lan