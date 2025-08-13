#!/bin/bash

# Deploy personal dotfiles using GNU Stow
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../dotfiles-overrides"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$(dirname "$DOTFILES_DIR")"
    stow -t "$HOME" dotfiles-overrides
fi