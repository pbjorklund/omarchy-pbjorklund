#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install Claude Code
show_action "Installing Claude Code"

# Install Claude Code via AUR with GitHub fallback
install_package "claude-code"