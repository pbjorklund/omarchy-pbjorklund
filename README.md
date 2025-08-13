# pbjorklund's Omarchy Configuration

Personal customizations and theme for [omarchy](https://omarchy.org) - Basecamp's opinionated Arch Linux + Hyprland desktop setup.

## What This Is

Personal overrides for omarchy that add additional applications, a custom theme, and development configurations while preserving omarchy's foundation.

## Prerequisites

**You must have omarchy installed first.**

1. Install Arch Linux + omarchy following instructions at https://omarchy.org
2. **Set up 1Password before running this script:**
   - Open 1Password desktop app (pre-installed with omarchy)
   - Sign in to your 1Password account
   - Import your SSH key named "pbjorklund-ssh" into 1Password
   - Enable SSH agent: Settings → Developer → "Use the SSH agent"
3. Run this script to apply personal customizations

## Quick Start

```bash
# Clone this repository
git clone <this-repo-url>
cd omarchy-pbjorklund

# Configure for your environment
cp config.env.example config.env
nano config.env

# Apply customizations to your existing omarchy installation  
bash install.sh
```

## Management Commands

```bash
# Switch back to pbjorklund theme
bash overrides/set-theme-pbjorklund.sh

# Reapply dotfiles after changes
cd dotfiles-overrides && stow -t $HOME .

# Compare configurations with omarchy defaults
bin/omarchy-compare-config ~/.config/hypr/bindings.conf
```

---

**Based on omarchy by DHH and 37signals**  
See https://omarchy.org for the base system