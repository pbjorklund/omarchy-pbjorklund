#!/bin/bash

# Install Node.js LTS using mise (already available in omarchy)
set -e

echo "Installing Node.js LTS with mise..."

# Check if Node.js is already installed
if command -v node &>/dev/null; then
  echo "Node.js already available: $(node --version)"
  echo "Skipping Node.js installation"
  return 0
fi

# Install Node.js LTS using mise
if command -v mise &>/dev/null; then
  echo "Installing Node.js LTS..."
  mise install node@lts
  mise use -g node@lts
  
  # Source mise to make node available in current session
  eval "$(mise activate bash)"
  
  if command -v node &>/dev/null; then
    echo "Node.js LTS installation completed: $(node --version)"
  else
    echo "Node.js LTS installation completed (will be available in new shells)"
  fi
else
  echo "ERROR: mise not found - please ensure omarchy installation is complete"
  return 1
fi