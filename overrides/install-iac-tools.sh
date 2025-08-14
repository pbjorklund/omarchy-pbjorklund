#!/bin/bash

# Install Infrastructure as Code tools
set -e

# Install Terraform
echo "Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    yay -S --noconfirm terraform
    echo "Terraform installed successfully"
else
    echo "Terraform already installed"
fi

# Install Ansible
echo "Installing Ansible..."
if ! command -v ansible &> /dev/null; then
    sudo pacman -S --noconfirm ansible
    echo "Ansible installed successfully"
else
    echo "Ansible already installed"
fi

echo "IaC tools installation complete"