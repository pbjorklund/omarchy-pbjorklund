#!/bin/bash

# Install GNU Stow for dotfiles management
if ! command -v stow &> /dev/null; then
    sudo pacman -S --noconfirm stow
fi