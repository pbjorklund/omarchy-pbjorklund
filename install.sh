#!/bin/bash
set -e

# INSTALL SCRIPT NAMING PATTERNS:
# install-*   - Package/software installation
# setup-*     - System configuration and setup
# configure-* - Hardware/service configuration
# uninstall-* - Package removal
# copy-*      - File deployment/copying
# link-*      - Symlink creation

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
init_logging "install"

# =============================================================================
# INSTALLATION STEPS - PRIMARY CONFIGURATION
# =============================================================================
# Format: "script-name.sh|Human readable description|SYSTEM_TYPE"
# SYSTEM_TYPE: ALL (both), THINKPAD (laptop only), DESKTOP (desktop only)

declare -a INSTALL_STEPS=(
  "setup-directories.sh|Development directories setup|ALL"
  "setup-passwordless-sudo.sh|Passwordless sudo setup|ALL"
  "remove-fcitx5.sh|fcitx5 input method removal|ALL"
  "remove-fcitx5-from-omarchy.sh|Remove fcitx5 from omarchy autostart|ALL"
  "install-bin-scripts.sh|Custom scripts installation|ALL"
  "install-bs-dependencies.sh|Bluesky poster dependencies|ALL"
  "install-stow.sh|Package managers installation|ALL"
  "link-dotfiles.sh|Personal dotfiles deployment|ALL"
  "install-node-lts.sh|Node.js LTS installation|ALL"
  "install-terminal-tools.sh|Terminal tools installation|ALL"
  "install-kanata.sh|Kanata keyboard remapper setup|ALL"
  "install-intel-vaapi.sh|Intel VAAPI for screen recording|THINKPAD"
  "install-amd-drivers.sh|AMD graphics drivers setup|DESKTOP"
  "install-displaylink.sh|DisplayLink drivers setup|THINKPAD"
  "setup-ssh-server.sh|SSH server setup|DESKTOP"
  "install-zen-browser.sh|Zen browser setup|ALL"
  "install-hosts.sh|Hosts file installation|ALL"
  "install-opencode.sh|OpenCode installation|ALL"
  "install-claude-code.sh|Claude Code setup|ALL"
  "install-onlyoffice.sh|ONLYOFFICE installation|ALL"
  "install-teams-for-linux.sh|Teams for Linux installation|ALL"
  "install-zotero.sh|Zotero installation|ALL"
  "install-plexamp.sh|Plexamp installation|ALL"
  "install-tidal-hifi.sh|Tidal HiFi installation|ALL"
  "install-youtube-music.sh|YouTube Music installation|ALL"
  "install-bsky.sh|Bluesky installation|ALL"
  "install-toot.sh|Mastodon CLI client installation|ALL"
  "install-tailscale.sh|Tailscale installation|ALL"
  "install-pbp.sh|Personal project setup|ALL"
  "copy-desktop-files.sh|Desktop files copying|ALL"
  "setup-desktop-suspend.sh|Desktop suspend and hypridle setup|ALL"
  "fix-waybar-stacking.sh|Fix waybar stacking on lock/unlock|ALL"
  "setup-network-resume.sh|Network resume after suspend setup|DESKTOP"
  "install-iac-tools.sh|Infrastructure as Code tools installation|ALL"
  "uninstall-typora.sh|Typora removal|ALL"
  "uninstall-spotify.sh|Spotify removal|ALL"
  "remove-polkit-gnome.sh|GNOME polkit agent removal|ALL"
  "install-hyprpolkitagent.sh|Hyprland polkit agent installation|ALL"
  "configure-polkit-fingerprint.sh|Polkit fingerprint authentication setup|ALL"
  "configure-audio.sh|USB Audio configuration|DESKTOP"
  "setup-mouse.sh|Gaming mouse configuration|DESKTOP"
  "setup-wake-on-lan.sh|Wake-on-LAN setup|DESKTOP"
  "setup-wake-sources.sh|Wake sources setup|ALL"
  "install-libation.sh|Libation audiobook downloader installation|DESKTOP"
)

# =============================================================================
# IMPLEMENTATION - ERROR HANDLING AND UTILITIES
# =============================================================================

handle_errors() {
  local exit_code=$?
  local line_number=$1
  echo
  echo -e "${RED}ERROR: Personal omarchy configuration failed at line $line_number (exit code: $exit_code)${NC}" | tee -a "$MAIN_LOG"
  echo -e "${CYAN}You can retry by running: bash install.sh${NC}" | tee -a "$MAIN_LOG"
  echo -e "${BLUE}Logs saved to: $LOG_DIR${NC}" | tee -a "$MAIN_LOG"
  exit $exit_code
}

cleanup_background_jobs() {
  jobs -p | xargs -r kill 2>/dev/null || true
  exit 0
}

trap 'handle_errors $LINENO' ERR
trap cleanup_background_jobs EXIT

run_installation_step() {
  local script_name="$1"
  local description="$2"
  local script_path="$OVERRIDES_DIR/$script_name"

  echo -e "${CYAN}Running:${NC} $description" | tee -a "$MAIN_LOG"

  local log_name="${script_name%.sh}"
  local temp_output="$LOG_DIR/${log_name}.log"
  local temp_error="$LOG_DIR/${log_name}.error.log"

  if (source "$script_path") >"$temp_output" 2>"$temp_error"; then
    if [ -s "$temp_output" ]; then
      cat "$temp_output" | tee -a "$MAIN_LOG"
      # Don't show "complete" if script already indicated it was skipped
      if ! grep -q "(already done)" "$temp_output"; then
        show_success "$description complete"
      fi
    else
      show_success "$description complete"
    fi
    [ ! -s "$temp_error" ] && rm -f "$temp_error"
    return 0
  else
    local exit_code=$?
    if [ -s "$temp_error" ]; then
      echo -e "${RED}Error output:${NC}" | tee -a "$MAIN_LOG"
      cat "$temp_error" | tee -a "$MAIN_LOG" >&2
    fi
    if [ -s "$temp_output" ]; then
      echo -e "${YELLOW}Script output:${NC}" | tee -a "$MAIN_LOG"
      cat "$temp_output" | tee -a "$MAIN_LOG"
    fi
    show_error "$description failed (exit code: $exit_code) - check logs: $temp_output"
  fi
}

load_configuration() {
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if [ -f "$SCRIPT_DIR/config.env" ]; then
      source "$SCRIPT_DIR/config.env"
  else
      show_error "config.env not found at $SCRIPT_DIR/config.env - create from config.env.example"
  fi
}

validate_prerequisites() {
  [ -f "$HOME/.omarchy-preflight-complete" ] || show_error "Preflight setup not completed - run: bash preflight.sh"
  show_skip "Preflight checks passed (already done)"
  echo

  command -v pacman &> /dev/null || show_error "This script requires Arch Linux"
  [ "$EUID" -eq 0 ] && show_error "Do not run this script as root"
  [ -f "$HOME/.local/share/omarchy/install.sh" ] || show_error "Omarchy not found - please install omarchy first"
  command -v hyprctl &> /dev/null || show_error "Hyprland not found - ensure omarchy installation is complete"

  OVERRIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install-scripts"
}

show_completion_message() {
  echo | tee -a "$MAIN_LOG"
  echo -e "${BOLD}${GREEN}=========================================${NC}" | tee -a "$MAIN_LOG"
  echo -e "${BOLD}${GREEN}Personal omarchy configuration complete!${NC}" | tee -a "$MAIN_LOG"
  echo -e "${BOLD}${GREEN}=========================================${NC}" | tee -a "$MAIN_LOG"
  echo | tee -a "$MAIN_LOG"
  echo -e "${BOLD}${CYAN}OPTIONAL POST-SETUP STEPS:${NC}" | tee -a "$MAIN_LOG"
  echo -e "${YELLOW}  1. Setup NAS storage:${NC}" | tee -a "$MAIN_LOG"
  echo "     ./bin/setup-nas-storage.sh" | tee -a "$MAIN_LOG"
  echo "     This will mount your NAS shares and configure auto-mounting" | tee -a "$MAIN_LOG"
  echo | tee -a "$MAIN_LOG"
  echo -e "${YELLOW}  2. Connect to Headscale:${NC}" | tee -a "$MAIN_LOG"
  echo "     sudo tailscale up --login-server=$HEADSCALE_SERVER --accept-routes" | tee -a "$MAIN_LOG"
  echo "     Visit the authentication URL provided" | tee -a "$MAIN_LOG"
  echo "     Run: ./register-headscale-device.sh <token> (from homelab-iac repo)" | tee -a "$MAIN_LOG"
  echo "     Then use: tsui (TUI for managing Tailscale connections)" | tee -a "$MAIN_LOG"
  echo | tee -a "$MAIN_LOG"
  echo -e "${BOLD}${CYAN}MANAGEMENT COMMANDS:${NC}" | tee -a "$MAIN_LOG"
  echo "  Reset to omarchy defaults: omarchy-refresh-hyprland" | tee -a "$MAIN_LOG"
  echo "  Compare configs: omarchy-compare-config ~/.config/hypr/bindings.conf" | tee -a "$MAIN_LOG"
  echo "  Reapply configs: cd dotfiles-overrides && stow -t \$HOME ." | tee -a "$MAIN_LOG"

  echo -e "${CYAN}Script execution finished at $(date)${NC}" | tee -a "$MAIN_LOG"
  echo -e "${BLUE}Logs saved to: $LOG_DIR${NC}" | tee -a "$MAIN_LOG"
  echo -e "${GREEN}Exit status: 0${NC}" | tee -a "$MAIN_LOG"

  exec 1>&1 2>&2
  exit 0
}

show_header "Personal Omarchy Configuration"
echo | tee -a "$MAIN_LOG"

load_configuration
validate_prerequisites

SYSTEM_TYPE=$(get_system_type)

for step in "${INSTALL_STEPS[@]}"; do
  IFS='|' read -r script_name description system <<< "$step"

  if [[ "$system" == "$SYSTEM_TYPE" || "$system" == "ALL" ]]; then
    run_installation_step "$script_name" "$description"
  else
    show_skip "$description (skipped - ${SYSTEM_TYPE,,} detected)"
  fi
done

show_completion_message
