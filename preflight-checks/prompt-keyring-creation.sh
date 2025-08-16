#!/bin/bash
set -e

# Interactive keyring setup
echo "Setting up keyring configuration..."

if [ -d "$HOME/.local/share/keyrings" ] && [ -n "$(ls -A "$HOME/.local/share/keyrings" 2>/dev/null)" ]; then
    echo "✓ Keyring already configured"
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
    echo "✓ Keyring configuration complete"
fi