#!/bin/bash

# Deploy personal dotfiles using GNU Stow
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../dotfiles-overrides"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$(dirname "$DOTFILES_DIR")"
    echo "Deploying personal dotfiles..."
    
    # Handle VS Code directory structure to prevent full directory symlinking
    # Create the directory structure first so stow will only symlink files, not directories
    mkdir -p "$HOME/.config/Code/User"
    
    # Remove any existing VS Code settings that might conflict
    if [ -f "$HOME/.config/Code/User/settings.json" ] && [ ! -L "$HOME/.config/Code/User/settings.json" ]; then
        rm -f "$HOME/.config/Code/User/settings.json"
    fi
    
    # Handle Neovim lua directory to enable full config override
    # Remove omarchy's default nvim lua files so we can deploy our complete config
    if [ -d "$HOME/.config/nvim/lua" ] && [ ! -L "$HOME/.config/nvim/lua" ]; then
        echo "Removing omarchy default nvim lua config for full override..."
        rm -rf "$HOME/.config/nvim/lua"
    fi
    
    # Clean up any manually created symlinks that might conflict with stow
    # Remove LLM instruction symlinks if they exist (stow will recreate them)
    [ -L "$HOME/.claude/CLAUDE.md" ] && rm -f "$HOME/.claude/CLAUDE.md"
    [ -L "$HOME/.opencode/AGENTS.md" ] && rm -f "$HOME/.opencode/AGENTS.md"
    
    # Use stow restow for everything else
    # --no-folding prevents stow from creating directory symlinks
    stow -R --no-folding -t "$HOME" dotfiles-overrides
    
    echo "Personal dotfiles deployed successfully"
else
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
fi