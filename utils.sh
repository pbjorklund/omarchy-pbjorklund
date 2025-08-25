#!/bin/bash

# Color definitions (only for terminal output, not logs)

if [ -z "${RED+x}" ]; then
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
fi


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
    echo -e "${YELLOW}⊝${NC} $1" | tee -a "$MAIN_LOG"
}

show_header() {
    echo -e "${BOLD}${BLUE}$1${NC}" | tee -a "$MAIN_LOG"
}


install_package() {
    local package_name="$1"
    local github_repo="$2"  # optional: user/repo format
    local binary_name="${3:-$package_name}"  # optional: different binary name
    local install_method="${4:-release}"     # optional: release, source, or appimage
    
    # Check if already installed
    if ! command -v "$binary_name" &> /dev/null && ! pacman -Q "$package_name" &> /dev/null; then
        show_action "Installing $package_name via package manager"
        
        # Ensure LOG_DIR is set
        if [ -z "$LOG_DIR" ]; then
            init_logging "install-package"
        fi
        mkdir -p "$LOG_DIR"
        
        # Try yay installation (handles both repos and AUR)
        if yay -S --noconfirm "$package_name" > "$LOG_DIR/$package_name-yay.log" 2>&1; then
            show_success "$package_name installed via package manager"
            return 0
        fi
        
        # If GitHub repo provided and yay failed, try GitHub fallback
        if [[ -n "$github_repo" ]]; then
            show_action "Package manager failed, trying GitHub fallback for $package_name"
            
            # Create GitHub packages directory (gitignored)
            mkdir -p "./github-packages"
            echo "github-packages/" >> .gitignore
            
            case "$install_method" in
                "release")
                    install_from_github_release "$package_name" "$github_repo" "$binary_name"
                    ;;
                "source")
                    install_from_github_source "$package_name" "$github_repo" "$binary_name"
                    ;;
                "appimage")
                    install_from_github_appimage "$package_name" "$github_repo" "$binary_name"
                    ;;
                *)
                    show_error "Unknown install method: $install_method"
                    return 1
                    ;;
            esac
        else
            show_error "$package_name installation failed and no GitHub fallback provided (see $LOG_DIR/$package_name-yay.log)"
            return 1
        fi
    else
        if command -v "$binary_name" &> /dev/null; then
            show_success "$package_name already installed"
        elif pacman -Q "$package_name" &> /dev/null; then
            show_success "$package_name already installed"
        fi
    fi
}


install_from_github_release() {
    local package_name="$1"
    local github_repo="$2"
    local binary_name="$3"
    
    local package_dir="./github-packages/$package_name"
    local log_file="$(realpath $LOG_DIR)/$package_name-github.log"
    mkdir -p "$package_dir"
    
    show_action "Fetching latest release info for $github_repo"
    local release_url="https://api.github.com/repos/$github_repo/releases/latest"
    local release_info="$package_dir/release.json"
    
    if curl -sL "$release_url" > "$release_info" 2>"$log_file"; then
        # Try to find appropriate asset for Linux x86_64
        local download_url=$(grep -o '"browser_download_url": "[^"]*' "$release_info" | \
                           grep -E '\.(tar\.gz|tar\.xz|tar\.bz2|zip|deb|AppImage)$' | \
                           grep -E '(linux|x86_64|x86-64|amd64)' | \
                           head -1 | cut -d'"' -f4)
        
        if [[ -n "$download_url" ]]; then
            local filename=$(basename "$download_url")
            show_action "Downloading $filename from GitHub"
            
            if wget -q "$download_url" -O "$package_dir/$filename" 2>>"$log_file"; then
                install_github_binary "$package_dir" "$filename" "$binary_name" "$package_name" "$log_file"
            else
                show_error "Failed to download $filename from GitHub (see $log_file)"
                return 1
            fi
        else
            show_error "Could not find suitable Linux binary in GitHub releases"
            return 1
        fi
    else
        show_error "Failed to fetch GitHub release info (see $LOG_DIR/$package_name-github.log)"
        return 1
    fi
}


install_from_github_appimage() {
    local package_name="$1"
    local github_repo="$2"
    local binary_name="$3"
    
    local package_dir="./github-packages/$package_name"
    mkdir -p "$package_dir"
    
    show_action "Fetching AppImage from $github_repo"
    local release_url="https://api.github.com/repos/$github_repo/releases/latest"
    local release_info="$package_dir/release.json"
    
    if curl -sL "$release_url" > "$release_info" 2>"$LOG_DIR/$package_name-github.log"; then
        local download_url=$(grep -o '"browser_download_url": "[^"]*AppImage[^"]*' "$release_info" | \
                           head -1 | cut -d'"' -f4)
        
        if [[ -n "$download_url" ]]; then
            local filename="$binary_name.AppImage"
            show_action "Downloading AppImage"
            
            if wget -q "$download_url" -O "$package_dir/$filename" 2>>"$(realpath $LOG_DIR)/$package_name-github.log"; then
                chmod +x "$package_dir/$filename"
                mkdir -p "$HOME/.local/bin"
                ln -sf "$(realpath "$package_dir/$filename")" "$HOME/.local/bin/$binary_name"
                show_success "$package_name AppImage installed to ~/.local/bin/$binary_name"
            else
                show_error "Failed to download AppImage (see $LOG_DIR/$package_name-github.log)"
                return 1
            fi
        else
            show_error "Could not find AppImage in GitHub releases"
            return 1
        fi
    else
        show_error "Failed to fetch GitHub release info (see $LOG_DIR/$package_name-github.log)"
        return 1
    fi
}


install_from_github_source() {
    local package_name="$1"
    local github_repo="$2"
    local binary_name="$3"
    
    local package_dir="./github-packages/$package_name"
    
    show_action "Cloning $github_repo source"
    if git clone "https://github.com/$github_repo.git" "$package_dir" 2>"$LOG_DIR/$package_name-github.log"; then
        cd "$package_dir"
        
        # Try common build methods
        if [[ -f "Makefile" ]]; then
            show_action "Building with make"
            if make 2>>"$LOG_DIR/$package_name-github.log"; then
                # Try to install or copy binary
                if make install 2>>"$LOG_DIR/$package_name-github.log"; then
                    show_success "$package_name built and installed from source"
                else
                    # Try to copy binary manually
                    if [[ -f "$binary_name" ]]; then
                        mkdir -p "$HOME/.local/bin"
                        cp "$binary_name" "$HOME/.local/bin/"
                        chmod +x "$HOME/.local/bin/$binary_name"
                        show_success "$package_name binary copied to ~/.local/bin"
                    else
                        show_error "Build completed but could not find or install binary"
                        return 1
                    fi
                fi
            else
                show_error "Build failed (see $LOG_DIR/$package_name-github.log)"
                return 1
            fi
        else
            show_error "No Makefile found - source installation not supported for this package"
            return 1
        fi
        
        cd - > /dev/null
    else
        show_error "Failed to clone $github_repo (see $LOG_DIR/$package_name-github.log)"
        return 1
    fi
}


install_github_binary() {
    local package_dir="$1"
    local filename="$2"
    local binary_name="$3"
    local package_name="$4"
    local log_file="$5"
    
    cd "$package_dir"
    
    case "$filename" in
        *.tar.gz|*.tar.xz|*.tar.bz2)
            tar -xf "$filename" 2>>"$log_file"
            ;;
        *.zip)
            unzip -q "$filename" 2>>"$log_file"
            ;;
        *.deb)
            show_action "Installing .deb package"
            if sudo dpkg -i "$filename" 2>>"$log_file"; then
                show_success "$package_name installed from .deb"
                cd - > /dev/null
                return 0
            else
                show_error "Failed to install .deb package (see $log_file)"
                cd - > /dev/null
                return 1
            fi
            ;;
        *.AppImage)
            chmod +x "$filename"
            mkdir -p "$HOME/.local/bin"
            ln -sf "$(realpath "$filename")" "$HOME/.local/bin/$binary_name"
            show_success "$package_name AppImage linked to ~/.local/bin/$binary_name"
            cd - > /dev/null
            return 0
            ;;
    esac
    
    # Look for binary in extracted contents (including symlinks)
    local found_binary=$(find . -name "$binary_name" \( -type f -executable -o -type l \) | head -1)
    if [[ -n "$found_binary" ]]; then
        mkdir -p "$HOME/.local/bin"
        if [[ -L "$found_binary" ]]; then
            # Handle symlinks - copy the target and create a wrapper
            local target=$(readlink "$found_binary")
            if [[ "$target" = /* ]]; then
                # Absolute symlink - create a wrapper script
                create_chromium_wrapper "$binary_name" "$(pwd)" "$target"
            else
                # Relative symlink - copy both the link and its target
                cp -r "$(dirname "$found_binary")"/* "$HOME/.local/share/$package_name/" 2>/dev/null || true
                create_chromium_wrapper "$binary_name" "$HOME/.local/share/$package_name" "$target"
            fi
        else
            cp "$found_binary" "$HOME/.local/bin/"
            chmod +x "$HOME/.local/bin/$binary_name"
        fi
        show_success "$package_name binary installed to ~/.local/bin"
    else
        # Try common binary locations (including symlinks)
        for path in usr/bin bin usr/local/bin .; do
            if [[ -f "$path/$binary_name" || -L "$path/$binary_name" ]]; then
                mkdir -p "$HOME/.local/bin" "$HOME/.local/share/$package_name"
                
                if [[ -L "$path/$binary_name" ]]; then
                    # Copy the entire lib directory structure for chromium
                    if [[ -d "usr/lib64/chromium-browser" ]]; then
                        mkdir -p "$HOME/.local/share/$package_name"
                        cp -r usr/lib64/chromium-browser/* "$HOME/.local/share/$package_name/"
                        create_chromium_wrapper "$binary_name" "$HOME/.local/share/$package_name" "./chrome"
                    else
                        cp -L "$path/$binary_name" "$HOME/.local/bin/"
                        chmod +x "$HOME/.local/bin/$binary_name"
                    fi
                else
                    cp "$path/$binary_name" "$HOME/.local/bin/"
                    chmod +x "$HOME/.local/bin/$binary_name"
                fi
                show_success "$package_name binary installed to ~/.local/bin"
                cd - > /dev/null
                return 0
            fi
        done
        show_error "Could not find binary '$binary_name' in downloaded package"
        cd - > /dev/null
        return 1
    fi
    
    cd - > /dev/null
}


create_chromium_wrapper() {
    local binary_name="$1"
    local install_dir="$2"
    local chrome_binary="$3"
    
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/$binary_name" << EOF
#!/bin/bash
# Wrapper script for ungoogled-chromium installed from GitHub
export CHROME_WRAPPER="\$0"
cd "$install_dir"
exec "$chrome_binary" "\$@"
EOF
    chmod +x "$HOME/.local/bin/$binary_name"
}

remove_package() {
    local package_name="$1"
    local binary_name="${2:-$package_name}"
    
    if pacman -Q "$package_name" &> /dev/null; then
        show_action "Removing $package_name via package manager"
        
        if [ -z "$LOG_DIR" ]; then
            init_logging "remove-package"
        fi
        mkdir -p "$LOG_DIR"
        
        if yay -R --noconfirm "$package_name" > "$LOG_DIR/$package_name-remove.log" 2>&1; then
            show_success "$package_name removed"
            return 0
        else
            show_error "$package_name removal failed (see $LOG_DIR/$package_name-remove.log)"
            return 1
        fi
    elif command -v "$binary_name" &> /dev/null; then
        local binary_path=$(which "$binary_name" 2>/dev/null)
        if [[ "$binary_path" == "$HOME/.local/bin/"* ]]; then
            show_action "Removing manually installed binary $binary_name"
            rm -f "$binary_path"
            
            # Clean up related files if they exist
            if [[ -d "$HOME/.local/share/$package_name" ]]; then
                rm -rf "$HOME/.local/share/$package_name"
            fi
            
            show_success "$binary_name removed from ~/.local/bin"
            return 0
        else
            show_error "$binary_name found at $binary_path but not in ~/.local/bin - manual removal required"
            return 1
        fi
    else
        show_skip "$package_name not installed"
        return 0
    fi
}

# System detection functions
get_system_type() {
    # Check for ThinkPad (has battery)
    if ls /sys/class/power_supply/BAT* &>/dev/null; then
        echo "THINKPAD"
        return
    fi

    # Check for desktop indicators (discrete GPU, multiple PCIe slots, etc.)
    if lspci | grep -E '(VGA|Display|3D).*AMD|Advanced Micro Devices|NVIDIA' &>/dev/null; then
        echo "DESKTOP"
        return
    fi

    # Fallback to desktop if unsure
    echo "DESKTOP"
}
