#!/bin/bash
set -e

echo "=== Omarchy Desktop Preflight Setup ==="
echo "This script prepares essential keyring and authentication setup before installation."
echo

# Check if we're running on Arch Linux
if ! command -v pacman &> /dev/null; then
    echo "Error: This script requires Arch Linux with pacman"
    exit 1
fi

# Function to check if 1Password is installed and configured
check_1password() {
    if ! command -v op &> /dev/null; then
        echo "❌ 1Password CLI not found"
        return 1
    fi
    
    if ! op account list &> /dev/null; then
        echo "❌ 1Password not signed in"
        return 1
    fi
    
    echo "✅ 1Password CLI configured"
    return 0
}

# Function to check if keyring is properly configured
check_keyring() {
    if ! command -v seahorse &> /dev/null; then
        echo "❌ Seahorse not installed"
        return 1
    fi
    
    # Check if we have a default keyring
    if ! gnome-keyring-daemon --version &> /dev/null; then
        echo "❌ GNOME Keyring not running"
        return 1
    fi
    
    echo "✅ Keyring system available"
    return 0
}

# Function to install seahorse and setup keyring daemon
install_and_setup_keyring() {
    echo "Installing seahorse (GNOME Keyring manager)..."
    yay -S --noconfirm seahorse < /dev/null
    
    echo "Starting gnome-keyring daemon..."
    # Start gnome-keyring daemon if not running
    if ! pgrep -x gnome-keyring-d >/dev/null; then
        eval $(gnome-keyring-daemon --start --components=secrets,ssh)
    fi
}

# Function to setup keyring
setup_keyring() {
    echo
    echo "=== Keyring Setup Required ==="
    echo "We need to setup your keyring for secure credential storage."
    echo
    echo "Steps to complete:"
    echo "1. Seahorse will open"
    echo "2. Right-click in the main area and select 'New' > 'Password Keyring'"
    echo "3. Name it 'Default' and set a password"
    echo "4. Right-click the new keyring and select 'Set as Default'"
    echo "5. Close Seahorse"
    echo
    read -p "Press Enter to open Seahorse..."
    
    # Launch seahorse
    seahorse &
    SEAHORSE_PID=$!
    
    echo "Seahorse is now open. Complete the keyring setup as described above."
    echo "When finished, close Seahorse and this script will continue."
    
    # Wait for seahorse to close
    wait $SEAHORSE_PID 2>/dev/null || true
    
    echo "Seahorse closed. Keyring should now be configured."
}

# Function to check if system reboot is needed
check_reboot_needed() {
    # Create a marker file to track if we've rebooted after keyring setup
    REBOOT_MARKER="$HOME/.omarchy-preflight-reboot"
    
    if [ ! -f "$REBOOT_MARKER" ]; then
        echo
        echo "=== Reboot Required ==="
        echo "A system reboot is required to complete keyring initialization."
        echo "After reboot, run this preflight script again to continue."
        echo
        touch "$REBOOT_MARKER"
        echo "Reboot marker created. Please reboot your system now."
        echo "Run: sudo reboot"
        exit 0
    fi
    
    echo "✅ Post-reboot check passed"
}

# Function to validate all prerequisites
validate_prerequisites() {
    echo "=== Validating Prerequisites ==="
    
    local all_good=true
    
    if ! check_1password; then
        echo "Please install and configure 1Password first:"
        echo "1. Install 1Password from AUR: yay -S 1password"
        echo "2. Sign in to your 1Password account"
        echo "3. Enable SSH agent in 1Password settings"
        all_good=false
    fi
    
    if ! check_keyring; then
        all_good=false
    fi
    
    if [ "$all_good" = false ]; then
        return 1
    fi
    
    echo "✅ All prerequisites validated"
    return 0
}

# Main execution
main() {
    # Check if seahorse is installed, install if not
    if ! command -v seahorse &> /dev/null; then
        install_and_setup_keyring
    else
        # Even if seahorse is installed, ensure keyring daemon is running
        echo "Ensuring gnome-keyring daemon is running..."
        if ! pgrep -x gnome-keyring-d >/dev/null; then
            eval $(gnome-keyring-daemon --start --components=secrets,ssh)
        fi
    fi
    
    # Check if keyring needs setup
    if ! validate_prerequisites; then
        if ! command -v seahorse &> /dev/null; then
            echo "Error: Seahorse installation failed"
            exit 1
        fi
        
        setup_keyring
        check_reboot_needed
        
        # Re-validate after setup
        if ! validate_prerequisites; then
            echo "❌ Prerequisites still not met after setup"
            echo "Please ensure 1Password is configured and keyring is setup properly"
            exit 1
        fi
    fi
    
    # Create completion marker
    touch "$HOME/.omarchy-preflight-complete"
    
    echo
    echo "=== Preflight Complete ==="
    echo "✅ 1Password configured"
    echo "✅ Keyring setup complete"
    echo "✅ System ready for installation"
    echo
    echo "You can now run install.sh to continue with the desktop setup."
}

main "$@"