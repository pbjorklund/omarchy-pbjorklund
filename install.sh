#!/bin/bash

# Personal omarchy configuration script
# Applies custom overrides to an existing omarchy installation
set -e

catch_errors() {
  local exit_code=$?
  local line_number=$1
  echo
  echo "ERROR: Personal omarchy configuration failed at line $line_number (exit code: $exit_code)"
  echo "You can retry by running: bash install.sh"
  exit $exit_code
}

cleanup() {
  # Kill any background jobs
  jobs -p | xargs -r kill 2>/dev/null || true
  # Ensure we exit
  exit 0
}

trap 'catch_errors $LINENO' ERR
trap cleanup EXIT

# Function to run a script step with proper isolation and error handling
run_step() {
  local script_name="$1"
  local description="$2"
  local script_path="$OVERRIDES_DIR/$script_name"

  echo "Running: $description"

  # Capture output and errors, but show errors if script fails
  local temp_output=$(mktemp)
  local temp_error=$(mktemp)

  # Source script instead of executing in subshell, capture output
  if (source "$script_path") >"$temp_output" 2>"$temp_error"; then
    # Show any output from the script (allows scripts to control their own messaging)
    if [ -s "$temp_output" ]; then
      cat "$temp_output"
    fi
    echo "✓ $description complete"
    rm -f "$temp_output" "$temp_error"
    return 0
  else
    local exit_code=$?
    # Show errors when script fails
    if [ -s "$temp_error" ]; then
      echo "Error output:"
      cat "$temp_error" >&2
    fi
    if [ -s "$temp_output" ]; then
      echo "Script output:"
      cat "$temp_output"
    fi
    echo "✗ $description failed (exit code: $exit_code)"
    rm -f "$temp_output" "$temp_error"
    return $exit_code
  fi
}

# Function for special cases that need specific handling
run_inline_step() {
  local description="$1"
  shift
  local commands=("$@")

  echo "Running: $description"

  if "${commands[@]}"; then
    echo "✓ $description complete"
    return 0
  else
    local exit_code=$?
    echo "✗ $description failed (exit code: $exit_code)"
    return $exit_code
  fi
}

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/config.env" ]; then
    source "$SCRIPT_DIR/config.env"
else
    echo "Error: config.env not found at $SCRIPT_DIR/config.env"
    echo "Please create config.env from config.env.example"
    exit 1
fi

echo "Personal Omarchy Configuration"
echo

# Check preflight completion
if [ ! -f "$HOME/.omarchy-preflight-complete" ]; then
    echo "ERROR: Preflight setup not completed"
    echo
    echo "Please run the preflight script first:"
    echo "  bash preflight.sh"
    echo
    echo "This ensures:"
    echo "- 1Password is installed and configured"
    echo "- SSH key '$SSH_KEY_NAME' is imported into 1Password"
    echo "- SSH agent is enabled in 1Password Settings → Developer"
    echo "- Keyring (seahorse) is properly configured"
    echo "- System has been rebooted after keyring setup"
    echo
    exit 1
fi

echo "✅ Preflight checks passed"
echo

# Prerequisites check
if ! command -v pacman &> /dev/null; then
    echo "This script requires Arch Linux"
    exit 1
fi

if [ "$EUID" -eq 0 ]; then
    echo "Do not run this script as root"
    exit 1
fi

if [ ! -f "$HOME/.local/share/omarchy/install.sh" ]; then
    echo "Omarchy not found!"
    echo
    echo "Please install omarchy first:"
    echo "1. Download Arch Linux ISO and create bootable USB"
    echo "2. Follow installation instructions at https://omarchy.org"
    echo "3. Reboot into your omarchy system"
    echo "4. Then run this script to apply personal customizations"
    echo
    exit 1
fi

if ! command -v hyprctl &> /dev/null; then
    echo "Hyprland not found! Please ensure omarchy installation is complete."
    exit 1
fi

OVERRIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/overrides"

# Define installation steps as an array for easy management
declare -a INSTALL_STEPS=(
  "setup-directories.sh|Development directories setup"
  "install-bin-scripts.sh|Custom scripts installation"
  "install-stow.sh|Package managers installation"
  "link-dotfiles.sh|Personal dotfiles deployment"
  "install-node-lts.sh|Node.js LTS installation"
  "install-terminal-tools.sh|Terminal tools installation"
  "install-amd-drivers.sh|AMD graphics drivers setup"
  "install-zen-browser.sh|Zen browser setup"
  "install-screen-recorder.sh|Screen recorder setup"
  "install-opencode.sh|OpenCode setup"
  "install-claude-code.sh|Claude Code setup"
  "install-zotero.sh|Zotero installation"
  "install-plexamp.sh|Plexamp installation"
  "install-tailscale.sh|Tailscale installation"
  "install-pbp.sh|Personal project setup"
  "copy-desktop-files.sh|Desktop files copying"
  "setup-desktop-suspend.sh|Desktop suspend and hypridle setup"
  "setup-ssh-server.sh|SSH server setup"
  "install-iac-tools.sh|Infrastructure as Code tools installation"
  "uninstall-typora.sh|Typora removal"
  "uninstall-spotify.sh|Spotify removal"
  "configure-audio.sh|USB Audio configuration"
  "setup-mouse.sh|Gaming mouse configuration"
)

# Execute all steps
for step in "${INSTALL_STEPS[@]}"; do
  IFS='|' read -r script_name description <<< "$step"

  # Regular script execution
  run_step "$script_name" "$description"
done

echo
echo "========================================="
echo "Personal omarchy configuration complete!"
echo "========================================="
echo
echo "OPTIONAL POST-SETUP STEPS:"
echo "  1. Setup NAS storage:"
echo "     ./bin/setup-nas-storage.sh"
echo "     This will mount your NAS shares and configure auto-mounting"
echo
echo "  2. Connect to Headscale:"
echo "     sudo tailscale up --login-server=$HEADSCALE_SERVER --accept-routes"
echo "     Visit the authentication URL provided"
echo "     Run: ./register-headscale-device.sh <token> (from homelab-iac repo)"
echo "     Then use: tsui (TUI for managing Tailscale connections)"
echo
echo "MANAGEMENT COMMANDS:"
echo "  Reset to omarchy defaults: omarchy-refresh-hyprland"
echo "  Compare configs: omarchy-compare-config ~/.config/hypr/bindings.conf"
echo "  Reapply configs: cd dotfiles-overrides && stow -t \$HOME ."

# Ensure clean exit
echo "Script execution finished at $(date)"
echo "Exit status: 0"

# Force flush any remaining output
exec 1>&1 2>&2

# Explicit exit
exit 0
