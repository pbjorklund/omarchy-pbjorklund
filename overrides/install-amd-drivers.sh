#!/bin/bash

# Install AMD Radeon drivers for RX 9700 XT
set -e

echo "Installing AMD graphics drivers..."

# Check if AMD drivers are already properly installed
if pacman -Q mesa xf86-video-amdgpu vulkan-radeon radeontop >/dev/null 2>&1; then
    echo "AMD drivers already installed, skipping"
    exit 0
fi

# Install AMD graphics drivers (skip lib32 packages if there are conflicts)
echo "Installing main AMD packages..."
if ! sudo pacman -S --noconfirm --needed mesa xf86-video-amdgpu vulkan-radeon; then
    echo "ERROR: Failed to install main AMD graphics packages"
    echo "This may indicate a system package conflict"
    exit 1
fi

echo "Installing 32-bit AMD packages..."
if ! sudo pacman -S --noconfirm --needed lib32-mesa lib32-vulkan-radeon; then
    echo "WARNING: Could not install 32-bit packages due to conflicts"
    echo "32-bit applications may not work correctly"
fi

# Install AMD utilities
echo "Installing AMD utilities..."
if ! sudo pacman -S --noconfirm --needed radeontop; then
    echo "ERROR: Failed to install radeontop"
    exit 1
fi

echo "AMD graphics drivers installation completed"