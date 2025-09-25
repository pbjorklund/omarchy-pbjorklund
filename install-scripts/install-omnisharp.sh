#!/bin/bash

# Install OmniSharp for C# development
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils.sh"

init_logging

show_action "Installing OmniSharp C# language server"

# Install OmniSharp via AUR
install_package "omnisharp-roslyn"

# Verify installation
if command -v omnisharp &> /dev/null; then
    show_success "OmniSharp installed successfully"
    omnisharp --version > ./logs/omnisharp-version.log 2>&1 || true
else
    show_error "OmniSharp installation failed"
    return 1
fi