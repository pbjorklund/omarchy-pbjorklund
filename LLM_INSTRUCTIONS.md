# Arch Linux Desktop Setup - LLM Instructions

## MUST Follow
- Use `set -e` in new scripts
- Use `source` not `bash` in install.sh
- No interactive prompts
- Test on fresh Arch VM before committing

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
- Check pacman before AUR
- Use `yay -S --noconfirm` for AUR
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
