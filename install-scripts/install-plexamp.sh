#!/bin/bash

# Install Plexamp music client for Plex
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_package "plexamp-appimage"