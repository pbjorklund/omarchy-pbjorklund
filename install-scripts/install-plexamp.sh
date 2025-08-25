#!/bin/bash

# Install Plexamp music client for Plex
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install plexamp from AUR with GitHub fallback
echo "Installing Plexamp..."
install_package "plexamp-appimage"