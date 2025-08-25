#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
init_logging "install-toot"

show_action "Installing toot Mastodon CLI client"

install_package "toot"

show_success "toot Mastodon CLI client installed"