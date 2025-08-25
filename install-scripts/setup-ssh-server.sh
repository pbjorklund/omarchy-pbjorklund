#!/bin/bash

# Standalone SSH server setup for desktop machines
# Run this manually after main installation if SSH access is needed
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"
init_logging "ssh-setup"

show_header "=== SSH Server Setup ==="
echo -e "${CYAN}This will configure SSH server for remote access${NC}"
echo -e "${YELLOW}NOTE: This is intended for desktop machines only${NC}"
echo

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$SCRIPT_DIR/config.env" ]; then
    source "$SCRIPT_DIR/config.env"
else
    show_error "config.env not found at $SCRIPT_DIR/config.env - create from config.env.example"
fi

# Validate required configuration
if [ -z "$SSH_KEY_NAME" ]; then
    show_error "SSH_KEY_NAME not set in config.env"
fi


install_package "openssh"


show_action "Setting up SSH directory"
mkdir -p ~/.ssh > "$LOG_DIR/ssh-mkdir.log" 2>&1
chmod 700 ~/.ssh
show_success "SSH directory configured"

# Check for 1Password SSH agent and key
if ! [[ "$SSH_AUTH_SOCK" == *"1password"* ]] && [ ! -S "$HOME/.1password/agent.sock" ]; then
    show_error "1Password SSH agent not available - ensure it's configured in preflight"
fi

if ! ssh-add -L | grep -q "$SSH_KEY_NAME" 2>/dev/null; then
    echo
    echo -e "${YELLOW}SSH key '$SSH_KEY_NAME' not found in SSH agent${NC}"
    echo
    echo "To add your SSH key to 1Password:"
    echo -e "${YELLOW}1.${NC} Open 1Password"
    echo -e "${YELLOW}2.${NC} Create a new SSH Key item named '$SSH_KEY_NAME'"
    echo -e "${YELLOW}3.${NC} Or import an existing SSH key file"
    echo -e "${YELLOW}4.${NC} Ensure the key is available in SSH agent"
    echo
    echo -e "${CYAN}Then re-run this script${NC}"
    exit 1
fi

# Add SSH key to authorized_keys
show_action "Configuring authorized SSH keys"
ssh-add -L | grep "$SSH_KEY_NAME" > ~/.ssh/authorized_keys.tmp 2>"$LOG_DIR/ssh-key-extract.log"

if [ ! -f ~/.ssh/authorized_keys ] || ! grep -Fxf ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys >/dev/null 2>&1; then
    cat ~/.ssh/authorized_keys.tmp >> ~/.ssh/authorized_keys
    show_success "SSH key added to authorized_keys"
else
    show_skip "SSH key already in authorized_keys"
fi

rm ~/.ssh/authorized_keys.tmp
chmod 600 ~/.ssh/authorized_keys

# Configure SSH daemon for security
show_action "Configuring SSH daemon security"
sudo tee /etc/ssh/sshd_config.d/99-personal.conf > "$LOG_DIR/sshd-config.log" 2>&1 <<EOF
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
show_success "SSH daemon configured"

# Enable and start SSH service
show_action "Enabling SSH service"
sudo systemctl enable sshd > "$LOG_DIR/ssh-enable.log" 2>&1
sudo systemctl start sshd
show_success "SSH service started"

# Configure firewall
if command -v ufw >/dev/null 2>&1; then
    show_action "Configuring UFW firewall for SSH"
    sudo ufw allow from 192.168.0.0/16 to any port 22 > "$LOG_DIR/ufw-config.log" 2>&1
    sudo ufw allow from 100.64.0.0/10 to any port 22 >> "$LOG_DIR/ufw-config.log" 2>&1
    show_success "UFW firewall configured"
elif systemctl is-active --quiet firewalld; then
    show_action "Configuring firewalld for SSH"
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.0.0/16" service name="ssh" accept' > "$LOG_DIR/firewalld-config.log" 2>&1
    sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="100.64.0.0/10" service name="ssh" accept' >> "$LOG_DIR/firewalld-config.log" 2>&1
    sudo firewall-cmd --reload >> "$LOG_DIR/firewalld-config.log" 2>&1
    show_success "Firewalld configured"
else
    echo -e "${YELLOW}⚠ No firewall detected - SSH access will be unrestricted${NC}" | tee -a "$MAIN_LOG"
fi

# Show connection information
echo | tee -a "$MAIN_LOG"
show_success "SSH server setup complete"
echo | tee -a "$MAIN_LOG"
echo -e "${BOLD}${CYAN}Connection Information:${NC}" | tee -a "$MAIN_LOG"

LOCAL_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null || echo 'Not found')
echo -e "${YELLOW}  Local IP:${NC} $LOCAL_IP" | tee -a "$MAIN_LOG"

if command -v tailscale >/dev/null 2>&1; then
    TAILSCALE_IP=$(tailscale ip 2>/dev/null || echo 'Not connected')
    echo -e "${YELLOW}  Tailscale IP:${NC} $TAILSCALE_IP" | tee -a "$MAIN_LOG"
fi

echo -e "${YELLOW}  SSH command:${NC} ssh $USER@<ip_address>" | tee -a "$MAIN_LOG"
echo | tee -a "$MAIN_LOG"
echo -e "${BOLD}${CYAN}Security Notes:${NC}" | tee -a "$MAIN_LOG"
echo "  - SSH access restricted to 192.168.x.x (local) and 100.x.x.x (Tailscale) networks" | tee -a "$MAIN_LOG"
echo "  - Public key authentication only (no passwords)" | tee -a "$MAIN_LOG"
echo "  - Root login disabled" | tee -a "$MAIN_LOG"
echo | tee -a "$MAIN_LOG"
echo -e "${BLUE}Logs saved to: $LOG_DIR${NC}" | tee -a "$MAIN_LOG"