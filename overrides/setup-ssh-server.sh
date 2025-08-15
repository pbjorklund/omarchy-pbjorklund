#!/bin/bash

# Setup SSH server for remote access
set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../config.env" ]; then
    source "$SCRIPT_DIR/../config.env"
else
    echo "Error: config.env not found"
    echo "Please create config.env from config.env.example"
    return 1
fi

# Validate required configuration
if [ -z "$SSH_KEY_NAME" ]; then
    echo "Error: SSH_KEY_NAME not set in config.env"
    return 1
fi

echo "Setting up SSH server..."

# Install OpenSSH server if not already installed
if ! pacman -Q openssh >/dev/null 2>&1; then
    echo "Installing OpenSSH server..."
    yay -S --noconfirm openssh < /dev/null >/dev/null 2>&1
else
    echo "OpenSSH server already installed"
fi

# Create SSH directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Get the SSH public key from 1Password SSH agent
if ssh-add -L | grep -q "$SSH_KEY_NAME"; then
    echo "Adding $SSH_KEY_NAME key to authorized_keys..."
    
    # Extract the SSH key and add it to authorized_keys
    ssh-add -L | grep "$SSH_KEY_NAME" > ~/.ssh/authorized_keys.tmp
    
    # Only update if the key isn't already there
    if [ ! -f ~/.ssh/authorized_keys ] || ! grep -Fxf ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys >/dev/null 2>&1; then
        cat ~/.ssh/authorized_keys.tmp >> ~/.ssh/authorized_keys
        echo "SSH key added to authorized_keys"
    else
        echo "SSH key already in authorized_keys"
    fi
    
    rm ~/.ssh/authorized_keys.tmp
    chmod 600 ~/.ssh/authorized_keys
else
    echo "ERROR: $SSH_KEY_NAME key not found in SSH agent"
    echo "Make sure 1Password SSH agent is running and key is loaded"
    return 1
fi

# Configure SSH daemon for security
echo "Configuring SSH daemon..."
sudo tee /etc/ssh/sshd_config.d/99-personal.conf >/dev/null <<EOF
# Personal SSH configuration
Port 22
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
AllowUsers $USER
MaxAuthTries 3

# Allow access from local network and tailnet
AllowUsers $USER@192.168.*
AllowUsers $USER@100.*
EOF

# Enable and start SSH service
echo "Enabling SSH service..."
sudo systemctl enable sshd >/dev/null 2>&1
sudo systemctl start sshd

# Configure firewall to allow SSH
if command -v ufw >/dev/null 2>&1; then
    echo "Configuring UFW firewall for SSH..."
    sudo ufw allow from 192.168.0.0/16 to any port 22 >/dev/null 2>&1
    sudo ufw allow from 100.64.0.0/10 to any port 22 >/dev/null 2>&1
elif systemctl is-active --quiet firewalld; then
    echo "Configuring firewalld for SSH..."
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.0.0/16" service name="ssh" accept' >/dev/null 2>&1
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="100.64.0.0/10" service name="ssh" accept' >/dev/null 2>&1
    sudo firewall-cmd --reload >/dev/null 2>&1
else
    echo "No firewall detected - SSH access will be unrestricted"
fi

# Get the machine's IP addresses for reference
echo "SSH server setup complete"
echo
echo "Connection information:"
echo "  Local IP: $(ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null || echo 'Not found')"
if command -v tailscale >/dev/null 2>&1; then
    TAILSCALE_IP=$(tailscale ip 2>/dev/null || echo 'Not connected')
    echo "  Tailscale IP: $TAILSCALE_IP"
fi
echo "  SSH command: ssh $USER@<ip_address>"
echo
echo "NOTE: SSH access is restricted to:"
echo "  - 192.168.x.x networks (local network)"
echo "  - 100.x.x.x networks (Tailscale)"
echo "  - Public key authentication only"