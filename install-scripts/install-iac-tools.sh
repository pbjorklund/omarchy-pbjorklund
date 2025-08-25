#!/bin/bash

# Install Infrastructure as Code tools
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Install Terraform
echo "Installing Terraform..."
install_package "terraform"

# Install Ansible
echo "Installing Ansible..."
install_package "ansible"

echo "IaC tools installation complete"