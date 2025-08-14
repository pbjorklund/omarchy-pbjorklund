#!/bin/bash

set -e

# Install Tailscale
echo "Installing Tailscale..."
curl -fsSL https://tailscale.com/install.sh | sh

# Install tsui for TUI management
echo "Installing tsui (Tailscale TUI)..."
curl -fsSL https://neuralink.com/tsui/install.sh | bash

echo "✓ Tailscale and tsui installed"