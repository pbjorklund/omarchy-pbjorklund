# Arch Linux Desktop Setup - LLM Instructions

## MUST Follow
- Use `set -e` in new scripts
- Use `source` not `bash` in install.sh
- No interactive prompts
- Test on fresh Arch VM before committing
- NEVER run interactive commands (pacman without --noconfirm, etc.)
- **ABSOLUTELY NO INTERACTIVE COMMANDS** - Never use commands that enter interactive modes:
  - No `vim`, `nano`, `emacs`, or any editors
  - No `less`, `more`, `tail -f`, `watch`, or pagers
  - No `git rebase -i`, `git add -i` or interactive Git commands
  - No `systemctl edit` or other interactive system tools
  - Always use non-interactive flags: `--noconfirm`, `--yes`, `--assume-yes`, `--non-interactive`
  - Redirect input with `< /dev/null` to prevent hanging on stdin
- **ALWAYS consult Arch Wiki first** - Before writing any installation script, especially for hardware drivers or system components, check the official Arch Wiki documentation to understand the proper installation method and avoid unnecessary complexity

## Output Style Guidelines (Match Omarchy)
- **NO EMOJIS** - omarchy uses clean text only
- **Minimal output** - focus on essential progress messages
- **Silent scripts** - individual sourced scripts should be mostly quiet
- **Clean messaging**: Use format like "Installing personal applications" not "🎨 Installing additional applications..."
- **Error handling**: Simple, direct error messages without decoration
- **Progress style**: Brief status lines like omarchy's "Installing terminal tools [2/5]"
- **No explanatory text** - avoid verbose descriptions during installation
- **Management commands**: List simply at end, no bullet styling

## User Messaging Standards
Scripts must inform users about what's being done using consistent patterns:

### Status Messages
- **Action in progress**: `echo "Installing package..."` (present progressive, lowercase, end with ...)
- **Success**: `echo "✓ Package installed"` or `echo "✓ Package already installed"`
- **Error**: `echo "✗ Package installation failed"` or `echo "Error: Description"`
- **Skipping**: `echo "Package already installed, skipping"`

### Message Timing
- **Before action**: Show what's about to happen only when the action will actually be performed
- **After success**: Confirm completion with ✓ 
- **Skip messages**: Only show when actually skipping, not on every run

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
- Scripts sourced by `install.sh` should be mostly silent - let the parent script handle messaging
- Use `echo` sparingly in sourced scripts, only for critical user feedback
- The `run_step()` function in `install.sh` handles "Running:" and "✓ complete" messages

## Package Rules
- Use `yay -S --noconfirm` for all packages (handles both official repos and AUR)
- Log package installs to `./logs/` directory instead of `/dev/null` for debugging
- Add `> ./logs/package-install.log 2>&1` to capture both stdout and stderr
- Flatpak for GUI apps

## Logging Standards
- **Create logs directory**: All scripts should ensure `mkdir -p ./logs` exists
- **Package installs**: `yay -S --noconfirm package > ./logs/package-name.log 2>&1`
- **Command output**: Redirect verbose commands to logs instead of /dev/null
- **Log rotation**: Don't implement - keep it simple, logs folder is gitignored
- **Error visibility**: Still show errors to user, but also capture in logs for debugging

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
- Desktop-only (no laptop features)
- Wayland-first (no X11)
- Script execution order matters

## Key Paths
- Add software to `overrides/apps.sh`
- Config overrides in `overrides/dotfiles.sh`
- Desktop integration in `overrides/desktop.sh`
- Source new scripts from `install.sh`

## Common Gotchas
- Scripts are sourced, not executed (affects variable scope)
- No rollback mechanism - changes are permanent
- Hardcoded for Arch package names only
- Manual dotfiles deployment required after install
- Security-first mindset - all changes affect system hardening
- AUR packages may fail if mirrors are down
- Single-user system focus
- Error trap catches failures and shows retry instructions
- **CRITICAL FILE DISTINCTION**: 
  - **ROOT DIRECTORY FILES** (`LLM_INSTRUCTIONS.md`, `AGENTS.md`, `CLAUDE.md`): These are ONLY for working on the omarchy project itself. NEVER reference these when creating user-deployed files.
  - **DOTFILES-OVERRIDES DIRECTORY** (`dotfiles-overrides/`): Contains files that get deployed to users via stow. Any config files users need must be created HERE, not in root.
  - **LLM INSTRUCTION SYMLINKS**: All LLM instruction files in dotfiles-overrides should be symlinks to `../../templates/GLOBAL_LLM_INSTRUCTIONS.md`:
    - `dotfiles-overrides/.claude/CLAUDE.md` → `../../templates/GLOBAL_LLM_INSTRUCTIONS.md`
    - `dotfiles-overrides/.config/opencode/AGENTS.md` → `../../templates/GLOBAL_LLM_INSTRUCTIONS.md`
    - This ensures all AI tools get the same unified global instructions
  - **Never create separate LLM instruction files** - they should all point to the same global template

## Configuration Management
- All sensitive values (URLs, keys) go in `config.env` - never hardcode in scripts
- Scripts must load `config.env` before using variables
- Update both `config.env.example` and actual `config.env` when adding new variables
- SSH setup relies on 1Password SSH agent integration - scripts assume this is configured

## Code Style & Standards
- Follow existing patterns in the codebase
- Match omarchy's clean, minimal aesthetic (no decorative elements)
- Shell scripts use bash with `set -e` for strict error handling
- No sudo prompts - user runs install.sh as regular user
- Preserve omarchy's update compatibility - use overrides, not replacements
- **Use shared utilities**: Source `utils.sh` for common functions like `install_package()`, `show_success()`, etc.
- **Consistent messaging**: Use utility functions (`show_action()`, `show_success()`, `show_error()`) for consistent output formatting
- **NEVER use fallbacks** - Write code that works correctly, don't rely on fallback mechanisms to guard against failures. Code should be robust and handle edge cases properly, not depend on fallbacks to catch when it doesn't work

## Dotfiles & Stow Configuration
- **Dotfiles managed via GNU Stow** from `dotfiles-overrides/` directory
- **Omarchy integration**: omarchy provides base configs, we provide overrides via symlinks
- **Hyprland pattern**: omarchy's `hyprland.conf` sources both defaults AND our personal overrides
  - Keep omarchy's main `hyprland.conf` (orchestrates includes)
  - Our dotfiles provide individual `.conf` files that get symlinked and sourced
- **VS Code special handling**:
  - Create `~/.config/Code/User/` directory structure before stowing
  - Only symlink `settings.json`, never the entire `Code/` directory
  - VS Code needs to write additional files/dirs without conflicts
- **Stow flags**: Use `-R --no-folding` to prevent directory symlinks, allow file-level control
- **Initial deployment**: omarchy may pre-create some config files; stow `-R` handles existing symlinks but won't replace regular files
- **No `--adopt` flag**: This moves existing files INTO dotfiles, overwriting customizations
