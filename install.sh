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

trap 'catch_errors $LINENO' ERR

# Function to run a script step with proper isolation and error handling
run_step() {
  local script_name="$1"
  local description="$2"
  local script_path="$OVERRIDES_DIR/$script_name"
  
  echo "Running: $description"
  
  # Source script instead of executing in subshell
  if source "$script_path"; then
    echo "✓ $description complete"
    return 0
  else
    local exit_code=$?
    echo "✗ $description failed (exit code: $exit_code)"
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

echo "Personal Omarchy Configuration"
echo
echo "IMPORTANT: Ensure 1Password is set up before running this script:"
echo "- Sign in to 1Password desktop app"
echo "- Import SSH key 'pbjorklund-ssh' into 1Password"  
echo "- Enable SSH agent in 1Password Settings → Developer"
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
  "HYPRLAND_RELOAD|Hyprland configuration reload"
  "install-nvm.sh|Node.js runtime setup"
  "install-amd-drivers.sh|AMD graphics drivers setup"
  "install-zen-browser.sh|Zen browser setup"
  "install-screen-recorder.sh|Screen recorder setup"
  "install-opencode.sh|OpenCode setup"
  "install-claude-code.sh|Claude Code setup"
  "install-1password-cli.sh|1Password CLI setup"
  "copy-desktop-files.sh|Desktop files copying"
  "set-theme-pbjorklund.sh|Personal theme application"
  "install-zotero.sh|Zotero installation"
)

# Execute all steps
for step in "${INSTALL_STEPS[@]}"; do
  IFS='|' read -r script_name description <<< "$step"
  
  if [[ "$script_name" == "HYPRLAND_RELOAD" ]]; then
    # Special handling for Hyprland reload
    echo "Running: $description"
    if hyprctl reload; then
      echo "✓ $description complete"
    else
      echo "⚠ Warning: $description failed (you may need to restart manually)"
    fi
  else
    # Regular script execution
    run_step "$script_name" "$description"
  fi
done

echo
echo "Personal omarchy configuration complete!"
echo
echo "Management commands:"
echo "  Reset to omarchy defaults: omarchy-refresh-hyprland"
echo "  Compare configs: omarchy-compare-config ~/.config/hypr/bindings.conf"
echo "  Reapply configs: cd dotfiles-overrides && stow -t \$HOME ."

# Ensure clean exit
exit 0