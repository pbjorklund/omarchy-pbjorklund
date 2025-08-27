#!/bin/bash
set -e

# Install dependencies for bs (Bluesky social media poster) script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_PATH="$SCRIPT_DIR/venv"

show_action() { echo "$1"; }
show_success() { echo "✓ $1"; }
show_error() { echo "✗ $1"; }

install_bs_dependencies() {
    show_action "Setting up bs script dependencies..."
    
    # Install system Python packages
    if ! pacman -Qi python-requests &>/dev/null; then
        show_action "Installing python-requests..."
        sudo pacman -S --noconfirm python-requests
        show_success "python-requests installed"
    else
        show_success "python-requests already installed"
    fi
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "$VENV_PATH" ]; then
        show_action "Creating Python virtual environment..."
        python3 -m venv "$VENV_PATH"
        show_success "Virtual environment created"
    else
        show_success "Virtual environment already exists"
    fi
    
    # Install atproto library in venv
    show_action "Installing atproto library..."
    "$VENV_PATH/bin/pip" install atproto requests > "$SCRIPT_DIR/logs/bs-setup.log" 2>&1
    show_success "atproto library installed"
    
    show_success "bs script dependencies ready"
}

mkdir -p "$SCRIPT_DIR/logs"
install_bs_dependencies