#!/bin/bash

# Install AMD-optimized screen recorder
set -e

# For AMD GPUs, use wl-screenrec (better for AMD than wf-recorder)
yay -S --noconfirm --needed wl-screenrec