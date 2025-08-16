#!/bin/bash
set -e

echo "Setting up desktop suspend configuration..."

# Update omarchy-menu suspend command to use PATH-based command
echo "Updating omarchy-menu suspend command..."
if [ -f "$HOME/.local/share/omarchy/bin/omarchy-menu" ]; then
    sed -i 's|\*Suspend\*) /[^;]*suspend-desktop[^;]*;|\*Suspend\*) suspend-desktop ;|' "$HOME/.local/share/omarchy/bin/omarchy-menu"
    sed -i 's|\*Suspend\*) systemctl suspend ;|\*Suspend\*) suspend-desktop ;|' "$HOME/.local/share/omarchy/bin/omarchy-menu"
    echo "✓ omarchy-menu suspend command updated to use PATH"
else
    echo "✓ omarchy-menu not found (may not be installed yet)"
fi

# Configure hypridle service
echo "Configuring hypridle service..."
systemctl --user enable hypridle.service >/dev/null 2>&1 || true
systemctl --user restart hypridle.service >/dev/null 2>&1 || true

# Verify hypridle is running
if systemctl --user is-active --quiet hypridle.service; then
    echo "✓ hypridle service is running"
else
    echo "✗ Warning: hypridle service failed to start"
fi

echo "✓ Desktop suspend setup complete!"
echo ""
echo "Configuration:"
echo "- Screensaver: 2.5 minutes"
echo "- Lock screen: 5 minutes"  
echo "- Display off: 5.5 minutes"
echo "- System suspend: 30 minutes"
echo ""
echo "Manual suspend: Use omarchy menu or run 'suspend-desktop'"