#!/bin/bash

# Install zen-browser from AUR
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Remove old GitHub AppImage installation if it exists
if [ -f "/opt/zen-browser/zen-browser.AppImage" ]; then
    echo "Removing old GitHub AppImage installation..."
    sudo rm -rf /opt/zen-browser
    echo "✓ GitHub AppImage removed"
fi

# Remove any leftover symlinks
if [ -L "/usr/bin/zen-browser" ]; then
    sudo rm -f /usr/bin/zen-browser
    echo "✓ Old zen-browser symlink removed"
fi

# Remove old custom desktop file if it exists
if [ -f "/usr/share/applications/zen.desktop" ]; then
    sudo rm -f /usr/share/applications/zen.desktop
    echo "✓ Old custom desktop file removed"
fi

# Remove old custom icon if it exists
if [ -f "/usr/share/icons/zen.png" ]; then
    sudo rm -f /usr/share/icons/zen.png
    echo "✓ Old custom icon removed"
fi

# Install zen-browser-bin from AUR (minimum version 1.15b)
if ! pacman -Qi zen-browser-bin > /dev/null 2>&1; then
    echo "Installing zen-browser-bin from AUR..."
    mkdir -p ./logs
    
    # Check available version from AUR specifically (not chaotic-aur)
    AVAILABLE_VERSION=$(yay -Si aur/zen-browser-bin 2>/dev/null | grep '^Version' | awk '{print $3}' | head -1)
    
    if [ -z "$AVAILABLE_VERSION" ]; then
        echo "✗ Could not determine available zen-browser-bin version from AUR"
        exit 1
    fi
    
    echo "Available version: $AVAILABLE_VERSION"
    
    # Extract version number for comparison (remove 'b' suffix and any package revision)
    AVAILABLE_NUM=$(echo "$AVAILABLE_VERSION" | sed 's/b.*$//' | sed 's/-.*//')
    MIN_VERSION="1.15"
    
    # Simple version comparison
    if [ "$(printf '%s\n' "$MIN_VERSION" "$AVAILABLE_NUM" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
        echo "✗ Available version ($AVAILABLE_VERSION) is older than minimum required (1.15b)"
        echo "   Please wait for AUR package to be updated or install manually from GitHub"
        exit 1
    fi
    
    # Install specifically from AUR (not chaotic-aur)
    if yay -S --noconfirm aur/zen-browser-bin > ./logs/zen-browser-install.log 2>&1; then
        echo "✓ Zen Browser $AVAILABLE_VERSION installed from AUR"
    else
        echo "✗ Failed to install zen-browser-bin (see ./logs/zen-browser-install.log)"
        exit 1
    fi
else
    # Check if installed version meets minimum requirement
    INSTALLED_VERSION=$(pacman -Qi zen-browser-bin | grep '^Version' | awk '{print $3}')
    INSTALLED_NUM=$(echo "$INSTALLED_VERSION" | sed 's/b.*$//' | sed 's/-.*//')
    MIN_VERSION="1.15"
    
    if [ "$(printf '%s\n' "$MIN_VERSION" "$INSTALLED_NUM" | sort -V | head -n1)" != "$MIN_VERSION" ]; then
        echo "Upgrading zen-browser-bin to meet minimum version requirement..."
        mkdir -p ./logs
        # Upgrade specifically from AUR (not chaotic-aur)
        if yay -S --noconfirm aur/zen-browser-bin > ./logs/zen-browser-upgrade.log 2>&1; then
            NEW_VERSION=$(pacman -Qi zen-browser-bin | grep '^Version' | awk '{print $3}')
            echo "✓ Zen Browser upgraded to $NEW_VERSION"
        else
            echo "✗ Failed to upgrade zen-browser-bin (see ./logs/zen-browser-upgrade.log)"
            exit 1
        fi
    else
        echo "✓ zen-browser-bin $INSTALLED_VERSION already installed"
    fi
fi

# Fix profile configuration if migrating from GitHub AppImage
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
if xdg-settings set default-web-browser zen-browser.desktop 2>/dev/null; then
    echo "✓ Default browser set successfully"
else
    echo "Warning: Could not set default browser (may need to set manually)"
fi

if xdg-mime default zen-browser.desktop x-scheme-handler/http 2>/dev/null && \
   xdg-mime default zen-browser.desktop x-scheme-handler/https 2>/dev/null; then
    echo "✓ MIME associations set successfully"
else
    echo "Warning: Could not set MIME associations (may need to set manually)"
fi

# Configure 1Password integration
sudo mkdir -p /etc/1password
sudo touch /etc/1password/custom_allowed_browsers

# Remove old zen entry if it exists (from AppImage version)
if sudo grep -q "^zen$" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    sudo sed -i '/^zen$/d' /etc/1password/custom_allowed_browsers
fi

# Add zen-bin entry for AUR package if not present
if ! sudo grep -q "^zen-bin$" /etc/1password/custom_allowed_browsers 2>/dev/null; then
    echo "zen-bin" | sudo tee -a /etc/1password/custom_allowed_browsers >/dev/null
    echo "✓ Added zen-bin to 1Password allowed browsers"
else
    echo "✓ zen-bin already in 1Password allowed browsers"
fi
