#!/bin/bash

set -e

echo "Fixing waybar stacking issue on lock/unlock..."

# Create backup of original omarchy-restart-waybar
if [[ ! -f /home/$USER/.local/share/omarchy/bin/omarchy-restart-waybar.backup ]]; then
    cp /home/$USER/.local/share/omarchy/bin/omarchy-restart-waybar /home/$USER/.local/share/omarchy/bin/omarchy-restart-waybar.backup
fi

# Fix omarchy-restart-waybar to prevent race conditions and clean up systemd scopes
cat > /home/$USER/.local/share/omarchy/bin/omarchy-restart-waybar << 'EOF'
#!/bin/bash

# Prevent concurrent executions with a lock file
LOCKFILE="/tmp/omarchy-restart-waybar.lock"

# Try to acquire lock, exit if already running
if ! mkdir "$LOCKFILE" 2>/dev/null; then
    exit 0
fi

# Cleanup lock on exit
trap 'rmdir "$LOCKFILE" 2>/dev/null || true' EXIT

# Stop all waybar systemd scope units
systemctl --user stop 'app-Hyprland-waybar-*.scope' 2>/dev/null || true

# Kill any remaining waybar processes  
pkill -x waybar 2>/dev/null || true

# Start waybar
uwsm app -- waybar >/dev/null 2>&1 &
EOF

# Make it executable
chmod +x /home/$USER/.local/share/omarchy/bin/omarchy-restart-waybar

echo "✓ Fixed waybar stacking issue"
echo "  - Added lock file to prevent concurrent restarts"
echo "  - Added systemd scope cleanup"
echo "  - Backup saved to omarchy-restart-waybar.backup"