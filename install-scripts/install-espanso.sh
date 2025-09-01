#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

init_logging "espanso"

install_package "espanso-wayland"

show_action "Setting Wayland capabilities"
sudo setcap "cap_dac_override+p" $(which espanso) > "$LOG_DIR/espanso-caps.log" 2>&1
show_success "Wayland capabilities set"

show_action "Registering systemd service"
espanso service register > "$LOG_DIR/espanso-service.log" 2>&1
show_success "Service registered"

if ! groups | grep -q input; then
    show_action "Adding user to input group"
    sudo usermod -a -G input "$USER"
    show_success "Added to input group"
else
    show_success "Already in input group"
fi

show_action "Starting espanso service"
systemctl --user enable --now espanso > "$LOG_DIR/espanso-start.log" 2>&1
show_success "Espanso started"