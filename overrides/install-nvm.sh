#!/bin/bash

# Install nvm and latest LTS Node.js
set -e

echo "Setting up Node.js via NVM..."

# Check if node is already available
if command -v node &>/dev/null; then
  echo "Node.js already available: $(node --version)"
  return 0
fi

# Install nvm if not already installed
if [ ! -d "$HOME/.config/nvm" ] && [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
# Source nvm to make it available in current session
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# If NVM_DIR doesn't exist, try the old location
if [ ! -s "$NVM_DIR/nvm.sh" ] && [ -s "$HOME/.nvm/nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Install latest LTS Node.js if nvm is available
if command -v nvm &>/dev/null; then
  echo "Installing latest LTS Node.js..."
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
  echo "Node.js installation completed: $(node --version)"
else
  echo "WARNING: nvm not available in current session"
  echo "Please restart your shell and run 'nvm install --lts' manually"
fi
