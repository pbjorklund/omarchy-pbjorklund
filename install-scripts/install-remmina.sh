#!/bin/bash

set -e

# Source utils for package installation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

init_logging "remmina"

show_action "Installing Remmina remote desktop client"

# Install Remmina with RDP support
install_package "remmina"
install_package "freerdp"  # Required for RDP connections

show_success "Remmina remote desktop client installed with RDP support"