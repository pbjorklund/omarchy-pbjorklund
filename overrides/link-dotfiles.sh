#!/bin/bash

# Deploy personal dotfiles using GNU Stow
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../dotfiles-overrides"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$(dirname "$DOTFILES_DIR")"
    echo "Deploying personal dotfiles..."
    
    # Use stow restow to handle both initial deployment and updates atomically
    stow -R -t "$HOME" dotfiles-overrides
    
    echo "Personal dotfiles deployed successfully"
else
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
fi