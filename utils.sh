#!/bin/bash

# Color definitions (only for terminal output, not logs)
if [ -t 1 ]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly BOLD=''
    readonly NC=''
fi

# Initialize logging with timestamped run directory
init_logging() {
    if [ -z "$LOG_DIR" ]; then
        local script_name="${1:-install}"
        export LOG_DIR="./logs/${script_name}-$(date +%Y%m%d-%H%M%S)"
        mkdir -p "$LOG_DIR"
        export MAIN_LOG="$LOG_DIR/main.log"
        echo "=== Started at $(date) ===" > "$MAIN_LOG"
    fi
}

# Log to both main log and individual script log
log_command() {
    local command="$1"
    local script_name="$2"
    local success_msg="$3"
    local error_msg="$4"
    
    local script_log="$LOG_DIR/$script_name.log"
    
    if eval "$command" > "$script_log" 2>&1; then
        echo -e "${GREEN}✓${NC} $success_msg" | tee -a "$MAIN_LOG"
        return 0
    else
        echo -e "${RED}✗${NC} $error_msg (see $script_log)" | tee -a "$MAIN_LOG"
        exit 1
    fi
}

# Show consistent status messages and log them
show_action() {
    echo -e "${CYAN}$1...${NC}" | tee -a "$MAIN_LOG"
}

show_success() {
    echo -e "${GREEN}✓${NC} $1" | tee -a "$MAIN_LOG"
}

show_error() {
    echo -e "${RED}✗${NC} $1" | tee -a "$MAIN_LOG"
    exit 1
}

show_skip() {
    echo -e "${YELLOW}✓${NC} $1 ${YELLOW}(already done)${NC}" | tee -a "$MAIN_LOG"
}

show_header() {
    echo -e "${BOLD}${BLUE}$1${NC}" | tee -a "$MAIN_LOG"
}