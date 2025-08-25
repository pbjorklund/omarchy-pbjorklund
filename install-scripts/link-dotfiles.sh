#!/bin/bash

# Deploy personal dotfiles using GNU Stow
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../dotfiles-overrides"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$(dirname "$DOTFILES_DIR")"
    echo "Deploying personal dotfiles..."
    
    # Prevent full directory symlinking
    # Create directory structure first so stow symlinks files, not directories
    mkdir -p "$HOME/.config/Code/User"
    

    if [ -f "$HOME/.config/Code/User/settings.json" ] && [ ! -L "$HOME/.config/Code/User/settings.json" ]; then
        rm -f "$HOME/.config/Code/User/settings.json"
    fi
    
    # Remove shell config files that might conflict with stow
    for shell_config in .bash_profile .bashrc .zshrc; do
        if [ -f "$HOME/$shell_config" ] && [ ! -L "$HOME/$shell_config" ]; then
            echo "Removing existing $shell_config (not a symlink)..."
            rm -f "$HOME/$shell_config"
        fi
    done
    
    # Enable full config override
    # Remove omarchy's default nvim config if it hasn't been replaced by our symlinks yet
    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim/init.lua" ]; then
        echo "Removing omarchy default nvim config for full override..."
        rm -rf "$HOME/.config/nvim"
        mkdir -p "$HOME/.config/nvim"
    fi
    

    # Remove LLM instruction symlinks (stow will recreate them)
    [ -L "$HOME/.claude/CLAUDE.md" ] && rm -f "$HOME/.claude/CLAUDE.md"
    [ -L "$HOME/.opencode/AGENTS.md" ] && rm -f "$HOME/.opencode/AGENTS.md"
    
    # Use stow restow
    # --no-folding prevents stow from creating directory symlinks
    stow -R --no-folding -t "$HOME" dotfiles-overrides
    
    echo "Personal dotfiles deployed successfully"
else
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
fi