#!/bin/bash
set -e

source "$(dirname "$0")/../utils.sh"

echo "Installing kanata-tray and waybar integration..."

# Check if already installed
if command -v kanata-tray &> /dev/null; then
    echo "✓ kanata-tray already installed"
else
    mkdir -p ./logs

    # Install dependencies for tray integration
    show_action "Installing tray dependencies"
    if install_package libayatana-appindicator "libayatana-appindicator.log"; then
        show_success "Tray dependencies installed"
    else
        show_error "Failed to install tray dependencies (see ./logs/libayatana-appindicator.log)"
        exit 1
    fi

    # Download latest kanata-tray binary
    show_action "Downloading kanata-tray binary"
    LATEST_URL=$(curl -s https://api.github.com/repos/rszyma/kanata-tray/releases/latest | grep "browser_download_url.*linux" | cut -d '"' -f 4)

    if [ -z "$LATEST_URL" ]; then
        show_error "Failed to get download URL for kanata-tray"
        exit 1
    fi

    if curl -L "$LATEST_URL" -o /tmp/kanata-tray > ./logs/kanata-tray-download.log 2>&1; then
        show_success "kanata-tray binary downloaded"
    else
        show_error "Failed to download kanata-tray (see ./logs/kanata-tray-download.log)"
        exit 1
    fi

    # Install to user bin
    show_action "Installing kanata-tray to ~/.local/bin"
    mkdir -p ~/.local/bin
    chmod +x /tmp/kanata-tray
    mv /tmp/kanata-tray ~/.local/bin/kanata-tray

    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    fi

    show_success "kanata-tray installed to ~/.local/bin/kanata-tray"
fi

# Install waybar kanata status script
show_action "Installing waybar kanata status script"
mkdir -p ~/.local/bin
cp "$(dirname "$0")/../dotfiles-overrides/.local/bin/waybar-kanata-layer" ~/.local/bin/
chmod +x ~/.local/bin/waybar-kanata-layer
show_success "Waybar kanata status script installed"

# Create systemd user service for kanata-tray
if [ ! -f ~/.config/systemd/user/kanata-tray.service ]; then
    show_action "Creating systemd user service for kanata-tray"
    mkdir -p ~/.config/systemd/user

    cat > ~/.config/systemd/user/kanata-tray.service << 'EOF'
[Unit]
Description=Kanata Tray Icon
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/kanata-tray
Restart=on-failure
RestartSec=5
Environment=DISPLAY=:0

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable kanata-tray.service
    show_success "kanata-tray systemd service created and enabled"
else 
    echo "✓ kanata-tray systemd service already exists"
fi

echo "✓ kanata-tray installation complete"
echo ""
echo "Manual waybar setup required:"
echo "  1. Add 'custom/kanata-layer' to your waybar modules-right in ~/.config/waybar/config.jsonc"
echo "  2. Add the kanata module config from dotfiles-overrides/.config/waybar/config.jsonc"
echo "  3. Add kanata styling from dotfiles-overrides/.config/waybar/style.css"
echo "  4. Restart waybar: pkill waybar && waybar &"
echo "  5. Start kanata-tray: systemctl --user start kanata-tray.service"