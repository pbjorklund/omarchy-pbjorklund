#!/bin/bash

# Install GNU Stow for dotfiles management
if ! command -v stow &> /dev/null; then
    yay -S --noconfirm stow < /dev/null
fi