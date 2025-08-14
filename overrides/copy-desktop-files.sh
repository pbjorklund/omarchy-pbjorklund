#!/bin/bash

# Install desktop files for custom applications
APPLICATIONS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../applications" && pwd)"
DESKTOP_DIR="$HOME/.local/share/applications"

mkdir -p "$DESKTOP_DIR"

if [ -d "$APPLICATIONS_DIR/custom" ]; then
    for desktop_file in "$APPLICATIONS_DIR/custom"/*.desktop; do
        if [ -f "$desktop_file" ]; then
            filename="$(basename "$desktop_file")"
            # Backup existing file if it exists
            if [ -f "$DESKTOP_DIR/$filename" ]; then
                cp "$DESKTOP_DIR/$filename" "$DESKTOP_DIR/$filename.bak"
            fi
            cp "$desktop_file" "$DESKTOP_DIR/"
        fi
    done
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR"
fi