#!/bin/bash

# Setup NAS storage with automatic mounting
# Mounts NAS shares directly to /mnt/media, /mnt/pictures, /mnt/backups

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$SCRIPT_DIR/config.env" ]; then
    source "$SCRIPT_DIR/config.env"
else
    echo "Error: config.env not found at $SCRIPT_DIR/config.env"
    echo "Please create config.env with required variables"
    exit 1
fi

# Check required variables
if [ -z "$OP_NAS_ITEM_NAME" ] || [ -z "$NAS_IP" ] || [ ${#NAS_SHARES[@]} -eq 0 ]; then
    echo "Error: Missing required config variables in config.env"
    echo "Required: OP_NAS_ITEM_NAME, NAS_IP, NAS_SHARES"
    exit 1
fi

# Check 1Password CLI availability first
if ! command -v op &> /dev/null || ! op account list &> /dev/null 2>&1; then
    echo "Error: 1Password CLI not available or not signed in"
    echo "Please run: op signin or eval \$(op signin)"
    exit 1
fi

echo "Setting up NAS storage..."

# Install required packages
echo "Installing NAS storage packages..."
sudo pacman -S --noconfirm --needed cifs-utils > /dev/null 2>&1
yay -S --noconfirm autofs > /dev/null 2>&1

# Remove any existing mount directories (autofs direct mounts create them automatically)
for share in "${NAS_SHARES[@]}"; do
    sudo rmdir "/mnt/$share" 2>/dev/null || true
done

# Get credentials from 1Password using configured item name
NAS_USERNAME=$(op item get "$OP_NAS_ITEM_NAME" --fields username --reveal)
NAS_PASSWORD=$(op item get "$OP_NAS_ITEM_NAME" --fields password --reveal)

# Create CIFS credentials file
sudo tee /etc/cifs-nas-credentials > /dev/null << EOF
username=$NAS_USERNAME
password=$NAS_PASSWORD
EOF
sudo chmod 600 /etc/cifs-nas-credentials

# Configure autofs for direct mounts
sudo tee /etc/autofs/auto.master.d/nas.autofs > /dev/null << 'EOF'
/- /etc/autofs/auto.nas --timeout=60
EOF

# Create autofs map for direct NAS mounts
{
    for share in "${NAS_SHARES[@]}"; do
        echo "/mnt/$share -fstype=cifs,credentials=/etc/cifs-nas-credentials,uid=$USER,gid=$USER,iocharset=utf8,file_mode=0755,dir_mode=0755 ://$NAS_IP/$share"
    done
} | sudo tee /etc/autofs/auto.nas > /dev/null

# Enable and start autofs
sudo systemctl enable --now autofs

# Remove mount directories for direct mounts (autofs creates them)
for share in "${NAS_SHARES[@]}"; do
    sudo rmdir "/mnt/$share" 2>/dev/null || true
done

# Restart autofs to pick up the configuration
sudo systemctl restart autofs

echo "NAS storage configured - shares auto-mount at:"
for share in "${NAS_SHARES[@]}"; do
    echo "  /mnt/$share"
done