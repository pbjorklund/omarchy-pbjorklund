#!/bin/bash

# Deploy personal dotfiles using GNU Stow
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../dotfiles-overrides"

if [ -d "$DOTFILES_DIR" ]; then
    cd "$(dirname "$DOTFILES_DIR")"
    echo "Deploying personal dotfiles..."
    
    # Remove any existing stow links first
    stow -D dotfiles-overrides 2>/dev/null || true
    
    # Find all files in dotfiles that would conflict and back them up
    echo "Backing up conflicting files to ~/.config-backup-$(date +%s)..."
    BACKUP_DIR="$HOME/.config-backup-$(date +%s)"
    mkdir -p "$BACKUP_DIR"
    
    # Find all files in dotfiles-overrides and check for conflicts
    find dotfiles-overrides -type f | while read -r dotfile; do
        # Convert dotfiles-overrides/.bashrc to ~/.bashrc
        target_file="$HOME/${dotfile#dotfiles-overrides/}"
        
        if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
            echo "Backing up ${dotfile#dotfiles-overrides/}"
            mkdir -p "$BACKUP_DIR/$(dirname "${dotfile#dotfiles-overrides/}")"
            cp "$target_file" "$BACKUP_DIR/${dotfile#dotfiles-overrides/}"
            rm "$target_file"
        fi
    done
    
    # Now stow the dotfiles (this will create symlinks to our custom versions)
    stow -t "$HOME" dotfiles-overrides
    
    echo "Personal dotfiles deployed successfully"
    echo "Original configs backed up to: $BACKUP_DIR"
else
    echo "Dotfiles directory not found: $DOTFILES_DIR"
    return 1
fi