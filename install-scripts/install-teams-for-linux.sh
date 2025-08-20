#!/bin/bash

set -e
source "$(dirname "$(dirname "$0")")/utils.sh"

init_logging "install-teams-for-linux"

# Install Teams for Linux v2.3.0 using the electron-bin package
if ! command -v teams-for-linux-electron &> /dev/null; then
    show_action "Installing Teams for Linux v2.3.0"
    if yay -S --noconfirm teams-for-linux-electron-bin > "$LOG_DIR/teams-for-linux-install.log" 2>&1; then
        show_success "Teams for Linux v2.3.0 installed"
    else
        echo -e "${YELLOW}⊝${NC} Teams for Linux installation failed" | tee -a "$MAIN_LOG"
        echo -e "${CYAN}Alternative:${NC} Download manually from https://github.com/IsmaelMartinez/teams-for-linux/releases/tag/v2.3.0" | tee -a "$MAIN_LOG"
    fi
else
    show_success "Teams for Linux already installed"
    
    # Check if we need to upgrade to the electron-bin version for v2.3.0
    if pacman -Q teams-for-linux-electron-bin &> /dev/null; then
        show_success "Teams for Linux v2.3.0 (electron-bin) already installed"
    else
        show_action "Upgrading to Teams for Linux v2.3.0 (electron-bin)"
        # Remove old versions
        if pacman -Q teams-for-linux &> /dev/null; then
            sudo pacman -Runs --noconfirm teams-for-linux 2>/dev/null || true
        fi
        if pacman -Q teams-for-linux-bin &> /dev/null; then
            sudo pacman -Runs --noconfirm teams-for-linux-bin 2>/dev/null || true
        fi
        
        # Install new version
        if yay -S --noconfirm teams-for-linux-electron-bin > "$LOG_DIR/teams-upgrade.log" 2>&1; then
            show_success "Teams for Linux upgraded to v2.3.0"
        else
            echo -e "${YELLOW}⊝${NC} Teams for Linux upgrade failed" | tee -a "$MAIN_LOG"
        fi
    fi
fi

show_success "Teams for Linux setup complete"