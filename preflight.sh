#!/bin/bash
set -e

# PREFLIGHT SCRIPT NAMING PATTERNS:
# check-*     - Pure validation, no changes made
# setup-*     - Actual automated configuration  
# install-*   - Actual package installation
# start-*     - Actual service startup
# prompt-*    - User guidance for manual tasks

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
init_logging "preflight"

show_header "=== Preflight Setup ==="
echo -e "${CYAN}Configuring prerequisites for installation${NC}"
echo

# Define preflight checks directory
PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/preflight-checks"

# Define preflight checks in order
PREFLIGHT_CHECKS=(
  "check-system-requirements.sh|System requirements validation"
  "setup-passwordless-sudo.sh|Passwordless sudo setup"
  "install-keyring-manager.sh|Keyring manager installation"
  "start-keyring-daemon.sh|Keyring daemon startup"
  "prompt-keyring-creation.sh|Keyring creation prompt"
  "check-1password-ssh-agent.sh|1Password SSH agent validation"
)

# Function to run a preflight check
run_check() {
  local script_file="$1"
  local description="$2"
  local script_path="$PREFLIGHT_DIR/$script_file"
  
  if [ -f "$script_path" ]; then
    show_action "Running: $description"
    source "$script_path"
    show_success "✓ $description complete"
  else
    show_error "Preflight check not found: $script_path"
  fi
}

# Run all preflight checks
for check in "${PREFLIGHT_CHECKS[@]}"; do
  IFS="|" read -r script_file description <<< "$check"
  run_check "$script_file" "$description"
done

# Mark preflight as complete
touch "$HOME/.omarchy-preflight-complete"

echo
show_success "Prerequisites complete"
echo -e "${CYAN}Run install.sh to continue${NC}"
echo -e "${BLUE}Logs saved to: $LOG_DIR${NC}"