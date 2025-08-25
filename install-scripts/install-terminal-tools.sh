#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install terminal tools
install_package "tmux"
install_package "zellij"

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi