#!/bin/bash
set -e

echo "Installing mouse configuration tools"

# Install piper (GUI for configuring gaming mice)
yay -S --noconfirm piper

# libratbag should already be installed, but ensure it's there
sudo pacman -S --noconfirm --needed libratbag

echo "Configuring gaming mouse DPI settings"

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
    
    echo "Gaming mouse configured to 400 DPI"
else
    echo "No supported gaming mouse detected - skipping DPI configuration"
fi

echo "Mouse setup complete"