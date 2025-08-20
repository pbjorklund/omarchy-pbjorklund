#!/bin/bash

set -e

install_tidal_hifi() {
    echo "Installing Tidal Hi-Fi..."
    
    # Create logs directory
    mkdir -p ./logs
    
    # Check if already installed
    if command -v tidal-hifi &> /dev/null; then
        echo "✓ Tidal Hi-Fi already installed"
        return 0
    fi
    
    # Install from AUR (binary version to avoid SSH git clone issues)
    if yay -S --noconfirm tidal-hifi-bin > ./logs/tidal-hifi.log 2>&1; then
        echo "✓ Tidal Hi-Fi installed"
    else
        echo "✗ Tidal Hi-Fi installation failed (see ./logs/tidal-hifi.log)"
        return 1
    fi
}

install_tidal_hifi