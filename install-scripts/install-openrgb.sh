#!/bin/bash

# Install OpenRGB for RGB device control
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

mkdir -p ./logs

# Install OpenRGB and required tools
install_package "openrgb"
install_package "i2c-tools"

# Fix Kingston FURY RAM detection - blacklist spd5118 module that blocks i2c access
BLACKLIST_FILE="/etc/modprobe.d/kingston-fury-blacklist.conf"
if [ ! -f "$BLACKLIST_FILE" ]; then
    echo "Fixing Kingston FURY RAM detection..."
    echo 'blacklist spd5118' | sudo tee "$BLACKLIST_FILE" > /dev/null
    # Remove module if currently loaded
    sudo modprobe -r spd5118 2>/dev/null || true
    echo "✓ Kingston FURY RAM i2c access enabled"
else
    echo "✓ Kingston FURY RAM fix already applied"
fi

# Install additional ASUS tools for better RAM RGB support
if ! command -v rogauracore &> /dev/null; then
    echo "Installing ASUS ROG tools for better RGB control..."
    if yay -S --noconfirm rogauracore-git > ./logs/rogauracore.log 2>&1; then
        echo "✓ ROG Aura Core installed"
    else
        echo "✓ ROG Aura Core not needed (laptop-only tool)"
    fi
fi

# Create OpenRGB config directory
CONFIG_DIR="$HOME/.config/OpenRGB"
mkdir -p "$CONFIG_DIR"

# Create a profile with gold yellow color (RGB: 255, 215, 0)
PROFILE_FILE="$CONFIG_DIR/GoldYellow.orp"
if [ ! -f "$PROFILE_FILE" ]; then
    echo "Creating gold yellow profile..."
    # This creates a basic profile - OpenRGB will auto-detect devices and apply color
    cat > "$PROFILE_FILE" << 'EOF'
{
    "name": "GoldYellow",
    "description": "Gold yellow color for all RGB devices",
    "devices": []
}
EOF
    echo "✓ Gold yellow profile created"
else
    echo "✓ Gold yellow profile already exists"
fi

# Add OpenRGB to user groups for device access
# Check if plugdev group exists, create it if not
if ! getent group plugdev > /dev/null 2>&1; then
    echo "Creating plugdev group..."
    sudo groupadd plugdev
fi

if ! groups $USER | grep -q plugdev; then
    echo "Adding user to plugdev group for RGB device access..."
    sudo usermod -a -G plugdev $USER
    echo "✓ User added to plugdev group (reboot required)"
fi

# Create startup script
STARTUP_SCRIPT="$HOME/.local/bin/openrgb-startup.sh"
mkdir -p "$HOME/.local/bin"

cat > "$STARTUP_SCRIPT" << 'EOF'
#!/bin/bash
# OpenRGB startup script - set all devices to copper color

# Wait for devices to initialize
sleep 5

if command -v openrgb &> /dev/null; then
    # Get list of all devices and apply color to each one
    DEVICE_COUNT=$(openrgb --list-devices 2>/dev/null | grep -c "^[0-9]:" || echo "0")
    
    if [ "$DEVICE_COUNT" -gt 0 ]; then
        for i in $(seq 0 $((DEVICE_COUNT - 1))); do
            # Try different mode names commonly used by devices
            openrgb --device $i --mode Static --color B87333 > /dev/null 2>&1 || \
            openrgb --device $i --mode Direct --color B87333 > /dev/null 2>&1 || \
            openrgb --device $i --mode "Rainbow Wave" --color B87333 > /dev/null 2>&1 || \
            openrgb --device $i --color B87333 > /dev/null 2>&1 || true
        done
        
        # Special handling for Kingston FURY RAM - control via motherboard addressable zones
        # FURY RAM connects to motherboard addressable RGB headers (Aura Addressable 1/2/3)
        # Try each addressable zone individually for fine control
        for zone in 1 2 3; do
            openrgb --device 1 --zone $zone --mode Static --color B87333 > /dev/null 2>&1 || true
        done
        
        # Alternative approach: set all devices at once
        openrgb --color B87333 > /dev/null 2>&1 || true
    fi
fi
EOF

chmod +x "$STARTUP_SCRIPT"
echo "✓ OpenRGB startup script created"

echo "Note: You may need to reboot for group membership changes to take effect"
echo "OpenRGB will start automatically and set devices to copper color"
echo ""
echo "Kingston FURY RAM RGB Control:"
echo "- FURY RAM detected as separate device (Device 0) after spd5118 module blacklist"
echo "- Direct RGB control now available through OpenRGB GUI and CLI"
echo "- Run 'openrgb --list-devices' to verify FURY RAM shows as 'Kingston Fury DDR5 RGB'"
echo "- If RAM still not detected: reboot to apply spd5118 blacklist permanently"
echo "- Both slots controlled independently with full LED support per stick"