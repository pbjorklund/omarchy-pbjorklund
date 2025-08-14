# pbjorklund's Omarchy Configuration

Personal customizations and theme for [omarchy](https://omarchy.org) - Basecamp's opinionated Arch Linux + Hyprland desktop setup.

## What This Installs

This configuration adds the following to your omarchy installation:

### Development Tools
- **Terminal**: tmux with TPM plugin manager
- **Infrastructure**: Terraform, Ansible
- **Node.js**: NVM with latest LTS Node.js
- **Custom Scripts**: Personal development utilities

### Applications
- **Browser**: Zen Browser (replaces Chromium, includes 1Password integration)
- **Research**: Zotero reference manager
- **Media**: Plexamp music player
- **Development**: OpenCode, Claude Code
- **Security**: 1Password CLI

### System Configuration
- **Graphics**: AMD drivers
- **Audio**: USB audio configuration  
- **Networking**: Tailscale VPN
- **Theme**: pbjorklund custom theme (installed but not activated)
- **Dotfiles**: Personal configurations using GNU Stow

## Prerequisites

**You must have omarchy installed first.**

1. Install Arch Linux + omarchy following instructions at https://omarchy.org
2. **Set up 1Password before running this script:**
   - Open 1Password desktop app (pre-installed with omarchy)
   - Sign in to your 1Password account
   - Import your SSH key named "pbjorklund-ssh" into 1Password
   - Enable SSH agent: Settings → Developer → "Use the SSH agent"

## Installation

```bash
# Clone this repository
git clone <this-repo-url>
cd omarchy-pbjorklund

# Apply customizations to your existing omarchy installation  
bash install.sh
```

## Post-Installation

After installation, complete these steps:

1. **Set up keyring integration:**
   ```bash
   seahorse  # Create default keyring if prompted
   ```

2. **Connect to Tailscale/Headscale:**
   ```bash
   sudo tailscale up --login-server=https://headscale.pbjorklund.com --accept-routes
   # Visit authentication URL, then use: tsui
   ```

## Management Commands

```bash
# Install pbjorklund theme (available but not set as current)
bash overrides/install-theme-pbjorklund.sh

# Reapply dotfiles after changes
cd dotfiles-overrides && stow -t $HOME .

# Compare configurations with omarchy defaults
bin/omarchy-compare-config ~/.config/hypr/bindings.conf

# Reset to omarchy defaults
omarchy-refresh-hyprland
```

---

**Based on omarchy by DHH and 37signals**  
See https://omarchy.org for the base system