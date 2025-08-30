#!/bin/bash
set -e

echo "Installing hosts file..."
mkdir -p ./logs
sudo cp /etc/hosts /etc/hosts.backup

# Download StevenBlack unified hosts file
echo "Downloading unified hosts file..."
curl -fsSL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts > ./logs/stevenblack-hosts.tmp 2>&1
echo "✓ Downloaded unified hosts"

# Combine base system hosts + StevenBlack + our additions
sudo tee /etc/hosts > /dev/null << 'EOF'
# Static table lookup for hostnames.
# See hosts(5) for details.
127.0.0.1        localhost
::1              localhost
EOF

# Append StevenBlack hosts (skip their header)
sudo sh -c 'tail -n +10 ./logs/stevenblack-hosts.tmp >> /etc/hosts'

# Add our OpenCode-specific entries
sudo sh -c 'cat templates/hosts.txt >> /etc/hosts'

# Cleanup
rm -f ./logs/stevenblack-hosts.tmp

echo "✓ Unified hosts file installed"