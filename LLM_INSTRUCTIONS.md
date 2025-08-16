# Arch Linux Desktop Setup - LLM Instructions

## MUST Follow
- Use `set -e` in new scripts
- Use `source` not `bash` in install.sh
- No interactive prompts
- Test on fresh Arch VM before committing
- NEVER run interactive commands (pacman without --noconfirm, etc.)

## Output Style Guidelines (Match Omarchy)
- **NO EMOJIS** - omarchy uses clean text only
- **Minimal output** - focus on essential progress messages
- **Silent scripts** - individual sourced scripts should be mostly quiet
- **Clean messaging**: Use format like "Installing personal applications" not "🎨 Installing additional applications..."
- **Error handling**: Simple, direct error messages without decoration
- **Progress style**: Brief status lines like omarchy's "Installing terminal tools [2/5]"
- **No explanatory text** - avoid verbose descriptions during installation
- **Management commands**: List simply at end, no bullet styling

## Package Rules
- Use `yay -S --noconfirm` for all packages (handles both official repos and AUR)
- Add `< /dev/null` to prevent hanging on prompts
- Flatpak for GUI apps

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
