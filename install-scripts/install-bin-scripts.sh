#!/bin/bash

# Install custom scripts to /usr/local/bin
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin"

# Install scripts to /usr/local/bin (requires sudo)
for script in "$SCRIPT_DIR"/*; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        echo "Installing $script_name to /usr/local/bin/"
        sudo cp "$script" "/usr/local/bin/"
        sudo chmod 755 "/usr/local/bin/$script_name"
    fi
done