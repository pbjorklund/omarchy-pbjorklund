#!/bin/bash

# Replace chromium with zen browser
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Remove old AUR package if it exists
if pacman -Qi zen-browser-bin > /dev/null 2>&1; then
    echo "Removing old AUR zen-browser-bin package..."
    yay -R --noconfirm zen-browser-bin > ./logs/zen-removal.log 2>&1
    echo "✓ Old AUR package removed"
fi

# Download and install Zen Browser directly from GitHub
echo "Installing Zen Browser from GitHub..."
mkdir -p ./logs

# Get the latest release version from GitHub API
echo "Fetching latest Zen Browser version..."
ZEN_VERSION=$(curl -s https://api.github.com/repos/zen-browser/desktop/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$ZEN_VERSION" ]; then
    echo "✗ Failed to fetch latest version"
    exit 1
fi

echo "Latest version: $ZEN_VERSION"
ZEN_URL="https://github.com/zen-browser/desktop/releases/download/${ZEN_VERSION}/zen-x86_64.AppImage"

# Download to /opt/zen-browser
sudo mkdir -p /opt/zen-browser

if [ -f "/opt/zen-browser/zen-browser.AppImage" ]; then
    echo "Removing old version..."
    sudo rm -f /opt/zen-browser/zen-browser.AppImage
fi

echo "Downloading Zen Browser ${ZEN_VERSION}..."
if sudo wget -q --show-progress -O /opt/zen-browser/zen-browser.AppImage "$ZEN_URL" > ./logs/zen-download.log 2>&1; then
    sudo chmod 755 /opt/zen-browser
    sudo chmod 755 /opt/zen-browser/zen-browser.AppImage
    echo "✓ Zen Browser downloaded and installed"
else
    echo "✗ Failed to download Zen Browser (see ./logs/zen-download.log)"
    exit 1
fi

# Create desktop file
sudo tee /usr/share/applications/zen.desktop > /dev/null << 'EOF'
[Desktop Entry]
Version=1.0
Name=Zen Browser
Comment=Experience tranquillity while browsing the web
Exec=/opt/zen-browser/zen-browser.AppImage %U
Icon=zen
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

# Download icon
if [ ! -f "/usr/share/icons/zen.png" ]; then
    sudo wget -q -O /usr/share/icons/zen.png https://github.com/zen-browser/desktop/raw/main/src/browser/branding/zen/content/zen-wordmark.png > ./logs/zen-icon.log 2>&1
fi

# Fix profile configuration if migrating from AUR package
if [ -f "$HOME/.zen/profiles.ini" ]; then
    echo "Checking Zen Browser profile configuration..."
    
    # Check if we have multiple profiles and find the one with the most data
    if [ -d "$HOME/.zen" ]; then
        # Find the profile with the most data (largest prefs.js or most recent activity)
        MAIN_PROFILE=""
        MAX_SIZE=0
        
        for profile_dir in "$HOME/.zen"/*.*/; do
            if [ -d "$profile_dir" ] && [ -f "$profile_dir/prefs.js" ]; then
                profile_name=$(basename "$profile_dir")
                size=$(stat -c%s "$profile_dir/prefs.js" 2>/dev/null || echo 0)
                
                if [ "$size" -gt "$MAX_SIZE" ]; then
                    MAX_SIZE=$size
                    MAIN_PROFILE=$profile_name
                fi
            fi
        done
        
        if [ -n "$MAIN_PROFILE" ] && [ "$MAX_SIZE" -gt 10000 ]; then
            echo "Found main profile with data: $MAIN_PROFILE"
            
            # Create corrected profiles.ini with the main profile as default
            cat > "$HOME/.zen/profiles.ini" << EOF
[Profile0]
Name=Default (release)
IsRelative=1
Path=$MAIN_PROFILE
Default=1

[General]
StartWithLastProfile=1
Version=2

[Install15B76BAA26BA15E7]
Default=$MAIN_PROFILE
Locked=1
EOF
            echo "✓ Profile configuration updated to use main profile with your data"
        fi
    fi
fi

# Configure zen browser as default browser
echo "Setting zen browser as default..."
if xdg-settings set default-web-browser zen.desktop 2>/dev/null; then
    echo "Default browser set successfully"
else
    echo "Warning: Could not set default browser (may need to set manually)"
fi

if xdg-mime default zen.desktop x-scheme-handler/http 2>/dev/null && \
   xdg-mime default zen.desktop x-scheme-handler/https 2>/dev/null; then
    echo "MIME associations set successfully"
else
    echo "Warning: Could not set MIME associations (may need to set manually)"
fi

# Configure 1Password integration
sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers
if ! sudo grep -q "zen-bin" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
fi
