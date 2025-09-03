# Arch Linux Desktop Setup - LLM Instructions

## MUST Follow
- Use `set -e` in scripts
- Use `source` not `bash` in install.sh
- No interactive prompts
- Test on fresh Arch VM before committing
- **NO INTERACTIVE COMMANDS**:
  - No editors (`vim`, `nano`, `emacs`)
  - No pagers (`less`, `more`, `tail -f`, `watch`)
  - No interactive Git (`git rebase -i`, `git add -i`)
  - No interactive system tools (`systemctl edit`)
  - Always use flags: `--noconfirm`, `--yes`, `--non-interactive`
  - Redirect input: `< /dev/null`
- **NEVER INSTALL PACKAGES MANUALLY**:
  - Create scripts in `install-scripts/`
  - Add to `install.sh` INSTALL_STEPS array
  - Test via `source install-scripts/script-name.sh`
  - Use `install_package()` from `utils.sh`
- Consult Arch Wiki first for hardware/drivers
- No fallbacks - write correct code

## Output Style (Match Omarchy)
- No emojis
- Minimal output
- Silent sourced scripts
- Clean messaging: "Installing apps" not "🎨 Installing additional apps..."
- Simple error messages
- Brief progress: "Installing terminal tools [2/5]"
- No explanatory text
- Simple command lists

## User Messaging
### Status Messages
- **In progress**: `echo "Installing package..."` (lowercase, end with ...)
- **Success**: `echo "✓ Package installed"` or `echo "✓ Already installed"`
- **Error**: `echo "✗ Failed"` or `echo "Error: Description"`

### Message Timing
- Before action: Only when action will run
- After success: Confirm with ✓
- Skip messages: Only when actually skipping

### Examples
```bash
# Good - only shows when actually installing
if ! command -v package &> /dev/null; then
    echo "Installing package..."
    yay -S --noconfirm package < /dev/null
    echo "✓ Package installed"
else
    echo "✓ Package already installed"
fi

# Bad - shows message every run
echo "Installing package..."
if ! command -v package &> /dev/null; then
    yay -S --noconfirm package < /dev/null
fi
```

### Script Output Control
- Sourced scripts are mostly silent
- Use `echo` sparingly, only for critical feedback
- `run_step()` in `install.sh` handles "Running:" and "✓ complete"

## Packages & Logging
- **ALWAYS use `install_package()` from utils.sh** - Never manually implement installation
- **ALWAYS use `remove_package()` from utils.sh** - Never manually implement removal
- **ALWAYS use messaging functions**: `show_action()`, `show_success()`, `show_error()`, `show_skip()`
- Log to `./logs/` not `/dev/null`
- Format: `> ./logs/package-name.log 2>&1`
- Flatpak for GUI apps
- Always `mkdir -p ./logs` first
- Show errors to user AND capture in logs

### Installation Function Usage
```bash
# Standard package installation
install_package "package-name"

# With different binary name
install_package "package-name" "" "binary-name"

# With GitHub fallback
install_package "package-name" "user/repo" "binary-name" "release"
```

### Other Utils Functions
- `remove_package()` - Package removal
- `show_action()`, `show_success()`, `show_error()`, `show_skip()` - Consistent messaging
- `get_system_type()` - Detect DESKTOP/THINKPAD
- `init_logging()` - Initialize logging directory

### Logging Examples
```bash
# Good - capture logs for debugging
mkdir -p ./logs
if ! command -v package &> /dev/null; then
    echo "Installing package..."
    if yay -S --noconfirm package > ./logs/package.log 2>&1; then
        echo "✓ Package installed"
    else
        echo "✗ Package installation failed (see ./logs/package.log)"
        return 1
    fi
else
    echo "✓ Package already installed"
fi

# Bad - information lost to /dev/null
yay -S --noconfirm package < /dev/null
```

## Don't Break
- Desktop-only
- Wayland-first
- Script execution order matters

## Key Paths
- Software: `overrides/apps.sh`
- Config: `overrides/dotfiles.sh`
- Desktop: `overrides/desktop.sh`
- Source from: `install.sh`

## Common Gotchas
- Scripts sourced, not executed (variable scope)
- No rollback - changes permanent
- Arch package names only
- Manual dotfiles deployment after install
- Security-first mindset
- AUR mirrors may fail
- Single-user system
- Error trap shows retry instructions
- **FILE DISTINCTION**:
  - **ROOT FILES** (`LLM_INSTRUCTIONS.md`, etc.): Only for omarchy project work
  - **DOTFILES-OVERRIDES**: User-deployed files via stow
  - **LLM SYMLINKS**: All point to `../../templates/GLOBAL_LLM_INSTRUCTIONS.md`

## Configuration Management
- Sensitive values in `config.env`, never hardcode
- Scripts load `config.env` before use
- Update both `config.env.example` and actual file
- SSH assumes 1Password agent configured

## Code Style
- Follow existing patterns
- Match omarchy's minimal aesthetic
- Bash with `set -e`
- No sudo prompts - user runs as regular user
- Use overrides, not replacements
- Source `utils.sh` for shared functions
- No fallbacks - write correct code

## Dotfiles & Stow
- Managed via GNU Stow from `dotfiles-overrides/`
- Omarchy provides base, we provide overrides via symlinks
- **Hyprland**: Keep omarchy's main config, add individual `.conf` files
- **VS Code**: Create `~/.config/Code/User/` first, symlink only `settings.json`
- **Stow flags**: `-R --no-folding` for file-level control
- **No `--adopt`**: Moves files INTO dotfiles, overwrites customizations

## Security Patterns
- Hosts blocking via `templates/hosts.txt`
- Simple copying: `sudo sh -c 'cat template >> /etc/hosts'`
- Don't over-engineer
- Templates in `templates/`, copy via install scripts
- One thing per script
