#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
init_logging "preflight"

show_header "=== Preflight Setup ==="
echo -e "${CYAN}Configuring prerequisites for installation${NC}"
echo

command -v pacman &> /dev/null || show_error "Requires Arch Linux"
command -v yay &> /dev/null || show_error "yay not found (should be installed by omarchy)"

if sudo -n true 2>/dev/null; then
    show_skip "Passwordless sudo already enabled"
else
    show_action "Configuring passwordless sudo"
    echo "$(whoami) ALL=(ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/$(whoami)" > "$LOG_DIR/sudo-setup.log" 2>&1
    show_success "Passwordless sudo enabled"
fi

if command -v seahorse &> /dev/null; then
    show_skip "Keyring manager already installed"
else
    show_action "Installing keyring manager"
    log_command "yay -S --noconfirm seahorse" "seahorse-install" "Keyring manager installed" "Keyring manager installation failed"
fi

if pgrep -x gnome-keyring-d >/dev/null; then
    show_skip "Keyring daemon already running"
else
    show_action "Starting keyring daemon"
    eval $(gnome-keyring-daemon --start --components=secrets,ssh) > "$LOG_DIR/keyring-daemon.log" 2>&1
fi

if [ -d "$HOME/.local/share/keyrings" ] && [ -n "$(ls -A "$HOME/.local/share/keyrings" 2>/dev/null)" ]; then
    show_skip "Keyring already configured"
else
    echo
    show_header "=== Keyring Setup Required ==="
    echo "Create a keyring for secure credential storage:"
    echo -e "${YELLOW}1.${NC} Right-click → New → Password Keyring"
    echo -e "${YELLOW}2.${NC} Name it 'Default' with a secure password"
    echo -e "${YELLOW}3.${NC} Right-click keyring → Set as Default"
    echo -e "${YELLOW}4.${NC} Close when complete"
    echo
    read -p "Press Enter to open keyring manager..."
    
    seahorse > "$LOG_DIR/seahorse-gui.log" 2>&1 &
    wait $! 2>/dev/null || true
fi

if [[ "$SSH_AUTH_SOCK" == *"1password"* ]] || [ -S "$HOME/.1password/agent.sock" ]; then
    show_skip "1Password SSH agent already configured"
else
    show_error "1Password SSH agent not configured - enable in 1Password Settings → Developer → SSH Agent"
fi

touch "$HOME/.omarchy-preflight-complete"

echo
show_success "Prerequisites complete"
echo -e "${CYAN}Run install.sh to continue${NC}"
echo -e "${BLUE}Logs saved to: $LOG_DIR${NC}"