#!/bin/bash

set -e

# Install Tailscale
if ! command -v tailscale &> /dev/null; then
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "Tailscale already installed"
fi

# Install tsui for TUI management
if ! command -v tsui &> /dev/null; then
    echo "Installing tsui (Tailscale TUI)..."
    curl -fsSL https://neuralink.com/tsui/install.sh | bash
else
    echo "tsui already installed"
fi

echo "Tailscale and tsui installation complete"
echo "Note: Use 'tsui' command to manage Tailscale connections interactively"