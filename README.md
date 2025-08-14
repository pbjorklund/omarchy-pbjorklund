# pbjorklund's Omarchy Configuration

Personal customizations for [omarchy](https://omarchy.org) - Basecamp's opinionated Arch Linux + Hyprland desktop setup.

## Prerequisites

1. Install Arch Linux + omarchy following instructions at https://omarchy.org
2. **Set up 1Password:**
   - Sign in to 1Password desktop app
   - Import SSH key named "pbjorklund-ssh" 
   - Enable SSH agent: Settings → Developer → "Use the SSH agent"

## Installation

```bash
git clone <this-repo-url>
cd omarchy-pbjorklund
bash install.sh
```

## Post-Installation

1. Set up keyring: `seahorse`
2. Connect Tailscale: `sudo tailscale up --login-server=https://headscale.pbjorklund.com --accept-routes`

---

**Based on omarchy by DHH and 37signals**



---

**Based on omarchy by DHH and 37signals**  
See https://omarchy.org for the base system