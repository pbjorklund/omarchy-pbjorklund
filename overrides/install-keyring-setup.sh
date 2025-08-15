#!/bin/bash

# Install Seahorse and setup default gnome-keyring keyring
set -e

echo "Setting up keyring management..."

# Install seahorse for keyring management
if ! pacman -Q seahorse >/dev/null 2>&1; then
    echo "Installing Seahorse..."
    yay -S --noconfirm seahorse < /dev/null
else
    echo "Seahorse already installed"
fi

# Start gnome-keyring daemon if not running
if ! pgrep -x gnome-keyring-d >/dev/null; then
    echo "Starting gnome-keyring daemon..."
    eval $(gnome-keyring-daemon --start --components=secrets,ssh)
fi

echo "Keyring setup complete"
echo "NOTE: Launch Seahorse (seahorse) to create a default keyring if needed"
echo "This is required before 1Password can integrate with gnome-keyring"