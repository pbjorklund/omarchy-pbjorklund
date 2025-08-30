#!/bin/bash
set -e

# Find project root (where templates/ directory exists)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing hosts file..."
mkdir -p "$PROJECT_ROOT/logs"
sudo cp /etc/hosts /etc/hosts.backup

# Download StevenBlack unified hosts file
echo "Downloading unified hosts file..."
curl -fsSL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts > "$PROJECT_ROOT/logs/stevenblack-hosts.tmp" 2>&1
echo "✓ Downloaded unified hosts"

# Start with our template (includes base system + OpenCode entries)
sudo cp "$PROJECT_ROOT/templates/hosts.txt" /etc/hosts

# Append StevenBlack hosts (skip their header)
sudo sh -c "tail -n +10 '$PROJECT_ROOT/logs/stevenblack-hosts.tmp' >> /etc/hosts"

# Cleanup
rm -f "$PROJECT_ROOT/logs/stevenblack-hosts.tmp"

echo "✓ Unified hosts file installed"