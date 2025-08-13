#!/bin/bash

# Setup standard development directories
set -e

echo "Creating development directories"

# Create Projects directory if it doesn't exist
if [ ! -d "$HOME/Projects" ]; then
    mkdir -p "$HOME/Projects"
    echo "Created ~/Projects directory"
else
    echo "~/Projects directory already exists"
fi