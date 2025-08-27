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

show_success "Kanata installation complete"
echo "Note: Configuration files will be deployed during dotfiles setup"
echo "Note: Service will be enabled after dotfiles deployment"
echo "Note: Restart required for input group membership to take effect"
