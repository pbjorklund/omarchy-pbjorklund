#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

show_action "Installing mouse configuration tools"

# Install piper (GUI for configuring gaming mice)
if ! command -v piper >/dev/null 2>&1; then
    log_command "yay -S --noconfirm piper" "piper-install" "Piper installed" "Piper installation failed"
else
    show_skip "Piper already installed"
fi

# libratbag should already be installed, but ensure it's there
if ! pacman -Q libratbag >/dev/null 2>&1; then
    log_command "yay -S --noconfirm libratbag" "libratbag-install" "libratbag installed" "libratbag installation failed"
else
    show_skip "libratbag already installed"  
fi

show_action "Configuring gaming mouse DPI settings"

# Quick check if any gaming mouse is detected before sleeping
if ! ratbagctl list 2>/dev/null | grep -q "Logitech G Pro"; then
    echo "No supported gaming mouse detected - skipping DPI configuration"
    show_success "Mouse setup complete"
    exit 0
fi

# Wait a moment for ratbag to detect devices
sleep 2

# Check if Logitech G Pro is detected and configure it
if ratbagctl list | grep -q "Logitech G Pro"; then
    DEVICE_NAME=$(ratbagctl list | grep "Logitech G Pro" | cut -d: -f1)
    echo "Found gaming mouse: $DEVICE_NAME"
    
    # Set to 400 DPI for slower, more precise movement
    ratbagctl "$DEVICE_NAME" profile active set 0
    ratbagctl "$DEVICE_NAME" profile 0 resolution 0 dpi set 400
    ratbagctl "$DEVICE_NAME" profile 0 resolution active set 0
    
    show_success "Gaming mouse configured to 400 DPI"
else
    echo "No supported gaming mouse detected - skipping DPI configuration"
fi

show_success "Mouse setup complete"