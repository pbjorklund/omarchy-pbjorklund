#!/bin/bash

# Install nvm and latest LTS Node.js
set -e

# Install nvm if not already installed
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Source nvm to make it available in current session
export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Check if nvm is available, if not try alternative sourcing
if ! command -v nvm &>/dev/null; then
  # Try sourcing from common locations
  if [ -s "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
  fi
  if [ -s "$HOME/.zshrc" ]; then
    source "$HOME/.zshrc"
  fi
fi

# Install latest LTS Node.js if nvm is available
if command -v nvm &>/dev/null; then
  nvm install --lts
  nvm use --lts
  nvm alias default lts/*
else
  echo "Warning: nvm not available in current session. Please restart your shell and run 'nvm install --lts' manually."
fi

