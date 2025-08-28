#!/usr/bin/env bash
set -e

# Watches Kanata config and reloads service on save while tailing logs

CONFIG="${CONFIG:-/home/pbjorklund/.config/kanata/config.kbd}"
CONFIG_DIR="$(dirname "$CONFIG")"
CONFIG_BASENAME="$(basename "$CONFIG")"

mkdir -p ./logs

# Ensure inotifywait is present
if ! command -v inotifywait >/dev/null 2>&1; then
  echo "Installing inotify-tools..."
  if command -v yay >/dev/null 2>&1; then
    if yay -S --noconfirm inotify-tools > ./logs/inotify-tools-install.log 2>&1 || \
       yay -S --noconfirm inotify-tools-git >> ./logs/inotify-tools-install.log 2>&1; then
      echo "✓ inotify-tools installed"
    else
      echo "✗ inotify-tools installation failed (see ./logs/inotify-tools-install.log)"
      exit 1
    fi
  else
    echo "✗ yay not found; please install inotify-tools manually"
    exit 1
  fi
fi

if [ ! -f "$CONFIG" ]; then
  echo "Error: config not found at: $CONFIG"
  exit 1
fi

echo "Watching: $CONFIG"
echo "Starting log stream..."

# Start watcher in background (watch directory to catch atomic saves)
(
  inotifywait -m -e close_write -e moved_to --format '%f' "$CONFIG_DIR" | \
  while read -r fname; do
    # Only react to our target file
    if [ "$fname" != "$CONFIG_BASENAME" ]; then
      continue
    fi
    # Debounce quick successive events
    sleep 0.05

    echo "=== Config changed, restarting kanata ==="
    
    if systemctl --user restart kanata; then
      echo "=== Kanata restarted successfully ==="
    else
      echo "=== Kanata restart failed ==="
    fi
    
    echo "=== Current kanata status ==="
    systemctl --user status kanata --no-pager -l
    echo "=== Resume log stream ==="
  done
) &

# Tail logs in foreground
journalctl --user -u kanata -n 50 -f
