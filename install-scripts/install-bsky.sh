#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
init_logging "install-bsky"

show_action "Installing bsky CLI tool"

# Ensure mise is available
if ! command -v mise &> /dev/null; then
    show_error "mise is required but not installed"
fi

# Create directories
mkdir -p ~/.local/share/bsky
mkdir -p ~/.local/bin

# Check if bsky is already installed
if [ -f ~/.local/bin/bsky ]; then
    show_skip "bsky CLI already installed"
    exit 0
fi

# Install Go using mise if not already available
if ! mise which go &> /dev/null; then
    echo "Installing Go via mise..."
    mise use -g go@latest > "$SCRIPT_DIR/../$LOG_DIR/go-mise-install.log" 2>&1
    echo "✓ Go installed via mise"
fi

# Set up temporary environment for Go
eval "$(mise env bash)"

# Clone and build bsky in ~/.local/share
BSKY_DIR="$HOME/.local/share/bsky"
cd "$BSKY_DIR"

if [ ! -d "src" ]; then
    echo "Cloning bsky source..."
    git clone https://github.com/mattn/bsky.git src > "$SCRIPT_DIR/../$LOG_DIR/bsky-clone.log" 2>&1
    echo "✓ bsky source cloned"
fi

cd src
echo "Building bsky CLI..."
go build -o ~/.local/bin/bsky . > "$SCRIPT_DIR/../$LOG_DIR/bsky-build.log" 2>&1
echo "✓ bsky CLI built and installed"

show_success "bsky CLI installed to ~/.local/bin/bsky"
    
    # Cleanup
    cd /
    rm -rf "$temp_dir"
else
    show_skip "bsky CLI already installed"
fi