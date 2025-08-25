#!/bin/bash

# Install Infrastructure as Code tools
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_package "terraform"

install_package "ansible"

echo "IaC tools installation complete"