#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install GNU Stow for dotfiles management
install_package "stow"