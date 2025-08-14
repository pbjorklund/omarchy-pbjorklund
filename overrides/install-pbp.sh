#!/bin/bash

set -e

echo "Setting up pbp repository..."

# Ensure Projects directory exists
mkdir -p ~/Projects

# Clone the repository if it doesn't exist
if [ ! -d ~/Projects/pbp ]; then
    echo "Cloning pbp repository..."
    git clone https://github.com/pbjorklund/pbp ~/Projects/pbp
else
    echo "pbp repository already exists, updating..."
    cd ~/Projects/pbp
    git pull
fi

# Run dev-setup.sh if it exists
if [ -f ~/Projects/pbp/dev-setup.sh ]; then
    echo "Running pbp dev-setup..."
    cd ~/Projects/pbp
    bash dev-setup.sh
else
    echo "Warning: dev-setup.sh not found in pbp repository"
fi

echo "✓ pbp setup complete"