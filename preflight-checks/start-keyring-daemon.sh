#!/bin/bash
set -e

# Start keyring daemon
echo "Starting keyring daemon..."

if pgrep -x gnome-keyring-d >/dev/null; then
    echo "✓ Keyring daemon already running"
else
    echo "Starting keyring daemon..."
    eval $(gnome-keyring-daemon --start --components=secrets,ssh) > "$LOG_DIR/keyring-daemon.log" 2>&1
    echo "✓ Keyring daemon started"
fi