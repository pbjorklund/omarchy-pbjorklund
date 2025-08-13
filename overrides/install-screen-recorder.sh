#!/bin/bash

# Install AMD-optimized screen recorder
set -e

# For AMD GPUs, use wl-screenrec (better for AMD than wf-recorder)
if ! pacman -Q wl-screenrec >/dev/null 2>&1; then
    yay -S --noconfirm wl-screenrec
else
    echo "wl-screenrec already installed"
fi