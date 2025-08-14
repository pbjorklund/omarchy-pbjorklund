#!/bin/bash
set -e

echo "Setting up desktop suspend and wake configuration..."

# Fix omarchy-menu to use zen browser instead of chromium
echo "Fixing omarchy-menu browser reference..."
if [ -f "$HOME/.local/share/omarchy/bin/omarchy-menu" ]; then
    sed -i 's/setsid chromium --new-window --app=/setsid zen-browser --new-window --app=/' "$HOME/.local/share/omarchy/bin/omarchy-menu"
    sed -i 's|\*Suspend\*) systemctl suspend ;;|*Suspend*) /home/pbjorklund/omarchy-pbjorklund/bin/suspend-desktop.sh ;;|' "$HOME/.local/share/omarchy/bin/omarchy-menu"
fi

# Remove chromium desktop entry if it exists
if [ -f "applications/chromium.desktop" ]; then
    echo "Removing chromium desktop entry..."
    rm applications/chromium.desktop
fi

# Apply wake source configuration now
echo "Applying wake source configuration..."
/home/pbjorklund/omarchy-pbjorklund/bin/setup-wake-sources.sh

# Restart hypridle to apply new config
echo "Restarting hypridle..."
pkill hypridle || true
hypridle &

echo "Desktop suspend setup complete!"
echo ""
echo "Configuration:"
echo "- Screensaver: 2.5 minutes"
echo "- Lock screen: 5 minutes"  
echo "- Display off: 5.5 minutes"
echo "- System suspend: 30 minutes"
echo "- Wake source: Keyboard only"
echo ""
echo "Manual suspend: Use omarchy menu or run suspend-desktop.sh"