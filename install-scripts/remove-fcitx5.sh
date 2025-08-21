#!/bin/bash
set -e

source utils.sh

echo "Removing fcitx5 input method..."

# Stop fcitx5 if running
if pgrep -x "fcitx5" > /dev/null; then
    echo "Stopping fcitx5..."
    pkill fcitx5 || true
fi

# Remove fcitx5 packages
echo "Removing fcitx5 packages..."
if pacman -Q fcitx5 &> /dev/null; then
    yay -R --noconfirm fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt > ./logs/remove-fcitx5.log 2>&1
    echo "✓ fcitx5 packages removed"
else
    echo "✓ fcitx5 already removed"
fi

# Remove environment variables from shell profiles
echo "Cleaning up environment variables..."
for file in ~/.bashrc ~/.zshrc ~/.profile; do
    if [[ -f "$file" ]]; then
        sed -i '/export GTK_IM_MODULE=fcitx/d' "$file"
        sed -i '/export QT_IM_MODULE=fcitx/d' "$file"
        sed -i '/export XMODIFIERS=@im=fcitx/d' "$file"
        sed -i '/export SDL_IM_MODULE=fcitx/d' "$file"
    fi
done

# Remove fcitx5 config directory
if [[ -d ~/.config/fcitx5 ]]; then
    echo "Removing fcitx5 config directory..."
    rm -rf ~/.config/fcitx5
    echo "✓ fcitx5 config removed"
fi

# Remove autostart entry if it exists
if [[ -f ~/.config/autostart/fcitx5.desktop ]]; then
    rm ~/.config/autostart/fcitx5.desktop
    echo "✓ fcitx5 autostart removed"
fi

echo "✓ fcitx5 removal complete"
echo "Please restart your session for changes to take effect"