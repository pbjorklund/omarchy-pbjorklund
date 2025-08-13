#!/bin/bash

# Configure passwordless sudo for current user
set -e

USERNAME=$(whoami)

echo "Configuring passwordless sudo for user: $USERNAME"
echo

# Create sudoers file for the current user
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USERNAME

# Set proper permissions
sudo chmod 0440 /etc/sudoers.d/$USERNAME

echo "Passwordless sudo configured successfully!"
echo "You can now run sudo commands without entering a password."
echo
echo "To revert this change later, run:"
echo "  sudo rm /etc/sudoers.d/$USERNAME"