#!/bin/bash
set -e

source utils.sh

echo "Completely removing fcitx5 input method..."

mkdir -p ./logs

# Stop fcitx5 services
echo "Stopping fcitx5 services..."
systemctl --user stop app-org.fcitx.Fcitx5@autostart.service 2>/dev/null || true
systemctl --user disable app-org.fcitx.Fcitx5@autostart.service 2>/dev/null || true

# Stop fcitx5 processes
if pgrep -x "fcitx5" > /dev/null; then
    echo "Killing fcitx5 processes..."
    pkill fcitx5 || true
fi

# Remove fcitx5 packages
echo "Removing fcitx5 packages..."
if pacman -Q fcitx5 &> /dev/null; then
    # Remove individual packages that exist
    for pkg in fcitx5 fcitx5-gtk fcitx5-qt fcitx5-configtool fcitx5-im; do
        if pacman -Q "$pkg" &> /dev/null; then
            yay -R --noconfirm "$pkg" >> ./logs/remove-fcitx5.log 2>&1 || true
        fi
    done
    echo "✓ fcitx5 packages removed"
else
    echo "✓ fcitx5 packages already removed"
fi

# Remove all fcitx config directories
echo "Removing fcitx config directories..."
rm -rf ~/.config/fcitx5
rm -rf ~/.config/fcitx
rm -rf ~/omarchy-pbjorklund/dotfiles-overrides/.config/fcitx5
rm -rf ~/Projects/.config/fcitx5

# Remove fcitx environment configuration
rm -f ~/.config/environment.d/fcitx.conf
rm -f ~/.local/share/omarchy/config/environment.d/fcitx.conf

# Remove fcitx application files
echo "Removing fcitx application files..."
rm -f ~/.local/share/applications/*fcitx*
rm -f ~/.local/share/omarchy/applications/hidden/*fcitx*

# Remove autostart entries
rm -f ~/.config/autostart/fcitx5.desktop
rm -f ~/.config/autostart/org.fcitx.Fcitx5.desktop

# Remove environment variables from shell profiles
echo "Cleaning up environment variables..."
for file in ~/.bashrc ~/.zshrc ~/.profile ~/.bash_profile; do
    if [[ -f "$file" ]]; then
        sed -i '/export GTK_IM_MODULE=fcitx/d' "$file"
        sed -i '/export QT_IM_MODULE=fcitx/d' "$file"
        sed -i '/export XMODIFIERS=@im=fcitx/d' "$file"
        sed -i '/export SDL_IM_MODULE=fcitx/d' "$file"
        sed -i '/fcitx/d' "$file"
    fi
done

# Verify removal
echo "Verifying fcitx5 removal..."
remaining_packages=$(pacman -Qs fcitx | wc -l)
remaining_files=$(find ~/.config ~/.local/share -name "*fcitx*" 2>/dev/null | wc -l)

if [[ $remaining_packages -eq 0 && $remaining_files -eq 0 ]]; then
    echo "✓ fcitx5 completely removed and verified"
else
    echo "⚠ Some fcitx5 remnants may remain:"
    pacman -Qs fcitx 2>/dev/null || true
    find ~/.config ~/.local/share -name "*fcitx*" 2>/dev/null || true
fi

echo "Please restart your session for changes to take effect"