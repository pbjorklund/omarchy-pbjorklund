#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install keyring manager
echo "Installing keyring manager..."

install_package "seahorse"