#!/bin/bash

# Install AMD Radeon drivers for RX 9700 XT
set -e

echo "Installing AMD graphics drivers..."

# Check if AMD drivers are already properly installed
if pacman -Q mesa xf86-video-amdgpu vulkan-radeon radeontop >/dev/null 2>&1; then
    echo "AMD drivers already installed, skipping"
    return 0
fi

# Install AMD graphics drivers (skip lib32 packages if there are conflicts)
echo "Installing main AMD packages..."
if ! yay -S --noconfirm --needed mesa xf86-video-amdgpu vulkan-radeon < /dev/null; then
    echo "ERROR: Failed to install main AMD graphics packages"
    echo "This may indicate a system package conflict"
    return 1
fi

echo "Installing 32-bit AMD packages..."
if ! yay -S --noconfirm --needed lib32-mesa lib32-vulkan-radeon < /dev/null; then
    echo "WARNING: Could not install 32-bit packages due to conflicts"
    echo "32-bit applications may not work correctly"
fi

# Install AMD utilities
echo "Installing AMD utilities..."
if ! yay -S --noconfirm --needed radeontop < /dev/null; then
    echo "ERROR: Failed to install radeontop"
    return 1
fi

echo "AMD graphics drivers installation completed"