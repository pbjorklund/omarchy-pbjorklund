#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

show_action "Setting up pbp repository"

# Quick check if pbp is already working
if command -v pbp >/dev/null 2>&1 && [ -d ~/Projects/pbp ]; then
    show_skip "pbp already configured and working"
    exit 0
fi

# Ensure Projects directory exists
mkdir -p ~/Projects

# Clone the repository if it doesn't exist
if [ ! -d ~/Projects/pbp ]; then
    echo "Cloning pbp repository..."
    git clone https://github.com/pbjorklund/pbp ~/Projects/pbp
    NEED_SETUP=true
else
    # Check if we need to pull updates
    cd ~/Projects/pbp
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git ls-remote origin HEAD | cut -f1)
    
    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "pbp repository has updates, pulling..."
        git pull
        NEED_SETUP=true
    else
        show_skip "pbp repository already up to date"
        NEED_SETUP=false
    fi
fi

# Check if pbp command is already working before running dev-setup
if command -v pbp >/dev/null 2>&1 && [ "$NEED_SETUP" != "true" ]; then
    show_skip "pbp already configured and working"
else
    # Run dev-setup.sh if it exists
    if [ -f ~/Projects/pbp/dev-setup.sh ]; then
        echo "Running pbp dev-setup..."
        cd ~/Projects/pbp
        bash dev-setup.sh
    else
        echo "Warning: dev-setup.sh not found in pbp repository"
    fi
fi

show_success "pbp setup complete"