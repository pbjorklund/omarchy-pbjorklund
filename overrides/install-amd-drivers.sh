#!/bin/bash

# Install AMD Radeon drivers for RX 9700 XT
set -e

# Install AMD graphics drivers
sudo pacman -S --noconfirm mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon

# Install AMD utilities
sudo pacman -S --noconfirm radeontop