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
   - Add your SSH key to 1Password (generate new or import existing)
   - Note the SSH key name in 1Password and set `SSH_KEY_NAME` in `config.env` to match
   - Enable SSH agent in Settings → Developer → "Use the SSH agent"

## Installation

1. **Preflight Setup** (Essential - Run First):
   ```bash
   git clone <this-repo-url>
   cd omarchy-pbjorklund
   cp config.env.example config.env
   # Edit config.env with your values
   ./preflight.sh
   ```
   
   The preflight script will:
   - Install and configure seahorse (keyring manager)
   - Guide you through creating a default keyring
   - Validate 1Password setup
   - Require a system reboot after keyring setup

2. **Main Installation** (After Preflight + Reboot):
   ```bash
   ./install.sh
   ```

The install script sources each override script in sequence, with error handling and retry instructions on failure.

## Post-Installation

### Required Setup Steps
1. Restart terminal for SSH agent to take effect
2. Connect Tailscale: `sudo tailscale up --login-server=<your-headscale-server>`

### Optional Manual Setup

#### NAS Storage Setup
Run `./bin/setup-nas-storage.sh` to mount network storage shares. Requires:
- NAS credentials stored in 1Password (item name specified in `config.env`)
- Network connectivity to your NAS device

#### Zen Browser Configuration
1. Sign in with Mozilla account (note: pinned tabs don't sync)
2. Configure 1Password extension properly:
   - Disable 1Password extension temporarily
   - Turn off "save passwords" in browser settings
   - Re-enable 1Password extension
   - This prevents browser from saving passwords/form data (1Password handles this)

---

*Based on omarchy by DHH and 37signals*  
See https://omarchy.org for the base system