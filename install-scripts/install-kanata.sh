#!/bin/bash

set -e

source utils.sh

show_header "Setting up Kanata keyboard remapper"

# Create logs directory
init_logging "kanata"

# Add user to input and uinput groups for Kanata permissions
show_action "Adding user to input and uinput groups for keyboard access"

# Check and add to input group
if ! groups | grep -q input; then
    sudo usermod -a -G input "$USER"
    NEEDS_RESTART=true
else
    NEEDS_RESTART=false
fi

# Create uinput group if it doesn't exist
if ! getent group uinput > /dev/null 2>&1; then
    sudo groupadd uinput
fi

# Check and add to uinput group
if ! groups | grep -q uinput; then
    sudo usermod -a -G uinput "$USER"
    NEEDS_RESTART=true
fi

if [ "$NEEDS_RESTART" = true ]; then
    show_success "User added to required groups (restart required to take effect)"
else
    show_success "User already in required groups"
fi

# Install Kanata with cmd support via AUR
install_package "kanata-git" "jtroo/kanata" "kanata" "git"

# Install wtype for Wayland unicode support
install_package "wtype" "wtype" "wtype" "release"

# Create udev rule for uinput device permissions
show_action "Setting up uinput device permissions"
UDEV_RULE_FILE="/etc/udev/rules.d/99-uinput.rules"
if [ ! -f "$UDEV_RULE_FILE" ]; then
    echo 'KERNEL=="uinput", GROUP="uinput", MODE="0660"' | sudo tee "$UDEV_RULE_FILE" > /dev/null
    sudo udevadm control --reload-rules
    # Ensure uinput module is loaded with proper permissions
    sudo modprobe uinput
    show_success "uinput device permissions configured"
else
    show_success "uinput device permissions already configured"
fi

# Deploy systemd service if dotfiles are already stowed
if [ -f "$HOME/.config/systemd/user/kanata.service" ]; then
    show_action "Enabling kanata user service"
    systemctl --user daemon-reload
    systemctl --user enable kanata.service
    
    # Start the service if it's not already running
    if ! systemctl --user is-active kanata.service > /dev/null 2>&1; then
        systemctl --user start kanata.service
        show_success "Kanata service started"
    else
        show_success "Kanata service already running"
    fi
else
    show_success "Kanata service will be enabled after dotfiles deployment"
fi

show_success "Kanata installation complete"
echo "Note: Configuration files will be deployed during dotfiles setup"
echo "Note: Restart required for input group membership to take effect"
