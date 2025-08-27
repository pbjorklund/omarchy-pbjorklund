#!/bin/bash

set -e

source utils.sh

show_header "Setting up Kanata keyboard remapper"

# Create logs directory
init_logging "kanata"

# Add user to input group for Kanata permissions
show_action "Adding user to input group for keyboard access"
if ! groups | grep -q input; then
    sudo usermod -a -G input "$USER"
    show_success "User added to input group (restart required to take effect)"
else
    show_success "User already in input group"
fi

# Install Kanata with cmd support via AUR
install_package "kanata-git" "jtroo/kanata" "kanata" "git"

# Install wtype for Wayland unicode support
install_package "wtype" "wtype" "wtype" "release"

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
