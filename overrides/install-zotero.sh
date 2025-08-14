#!/bin/bash

# Install Zotero reference management application
set -e

if ! pacman -Q zotero-bin >/dev/null 2>&1; then
    echo "Installing Zotero..."
    yay -S --noconfirm --needed zotero >/dev/null 2>&1
    echo "Zotero installation complete"
else
    echo "Zotero already installed"
fi