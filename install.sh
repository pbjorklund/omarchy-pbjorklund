#!/bin/bash

set -e

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

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
init_logging "install"

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
    fi
    show_success "$description complete"
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
  show_skip "Preflight checks passed"
  echo

  command -v pacman &> /dev/null || show_error "This script requires Arch Linux"
  [ "$EUID" -eq 0 ] && show_error "Do not run this script as root"
  [ -f "$HOME/.local/share/omarchy/install.sh" ] || show_error "Omarchy not found - please install omarchy first"
  command -v hyprctl &> /dev/null || show_error "Hyprland not found - ensure omarchy installation is complete"

  OVERRIDES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/overrides"
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

for step in "${INSTALL_STEPS[@]}"; do
  IFS='|' read -r script_name description <<< "$step"
  run_installation_step "$script_name" "$description"
done

show_completion_message
