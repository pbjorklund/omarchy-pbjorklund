# pbjorklund's Omarchy Configuration

Personal customizations for [omarchy](https://omarchy.org) that preserve omarchy's update compatibility.

## Overview

This setup adds development tools, applications, and personal dotfiles to omarchy while maintaining compatibility with upstream updates. The override strategy differs by configuration type:

- **Hyprland configs**: Sourced by omarchy's main configs to allow upstream updates
- **Other dotfiles**: Symlinked via GNU Stow to override defaults

## Structure

- `overrides/` - Install scripts sourced by `install.sh`
- `dotfiles-overrides/` - Personal dotfiles deployed via Stow
- `applications/` - Custom desktop files
- `bin/` - Utility scripts

## Prerequisites

1. Complete omarchy installation from https://omarchy.org
2. Copy `config.env.example` to `config.env` and customize for your environment
3. Set up 1Password SSH agent:
   - Install 1Password desktop app from https://1password.com/downloads/linux/
   - Create or add your SSH key in 1Password
   - Note the SSH key name and set `SSH_KEY_NAME` in `config.env` to match
   - Enable SSH agent in Settings → Developer → "Use the SSH agent"

## Installation

```bash
git clone <this-repo-url>
cd omarchy-pbjorklund
cp config.env.example config.env
# Edit config.env with your values
./install.sh
```

The install script sources each override script in sequence, with error handling and retry instructions on failure.

## Post-Installation

1. Configure keyring: `seahorse` (creates default keyring for 1Password integration)
2. Restart terminal for SSH agent to take effect
3. Connect Tailscale: `sudo tailscale up --login-server=<your-headscale-server>`

---

*Based on omarchy by DHH and 37signals*  
See https://omarchy.org for the base system