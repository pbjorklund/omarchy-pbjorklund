#!/bin/bash

# Deploy personal dotfiles using GNU Stow
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../dotfiles-overrides"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$(dirname "$DOTFILES_DIR")"
    echo "Deploying personal dotfiles..."
    
    # Create VS Code directory structure first to avoid full symlink
    mkdir -p "$HOME/.config/Code/User"
    
    # Use stow restow to handle both initial deployment and updates atomically
    # --no-folding prevents stow from creating directory symlinks
    stow -R --no-folding -t "$HOME" dotfiles-overrides
    
    echo "Personal dotfiles deployed successfully"
else
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
fi