# 1Password CLI Connection Reset Investigation - 2025-08-22

## Problem
1Password CLI was failing with connection reset error:
```
[ERROR] connecting to desktop app: read: connection reset, make sure 1Password CLI is installed correctly, then open the 1Password app, select 1Password > Settings > Developer and make sure the 'Integrate with 1Password CLI' setting is turned on.
```

## Symptoms
- CLI integration setting was enabled in 1Password Settings → Developer
- SSH agent worked fine (`~/.1password/agent.sock` existed and functional)
- Browser integration worked fine (zen browser configured in `/etc/1password/custom_allowed_browsers`)
- Debug output showed "Session delegation enabled" and "NM request: NmRequestAccounts" before failing

## Investigation Journey

### 1. Initial Checks
- Verified CLI integration setting was enabled in 1Password app
- Confirmed 1Password processes were running
- Found existing sockets:
  - `~/.1password/agent.sock` (SSH agent - working)
  - `/run/user/1000/1Password-BrowserSupport.sock` (browser support - working)

### 2. Socket Analysis
Found three types of 1Password sockets:
```bash
# SSH agent socket
/home/pbjorklund/.1password/agent.sock

# Browser support socket  
/run/user/1000/1Password-BrowserSupport.sock

# CLI integration socket (abstract socket)
@/tmp/1Password-1000/U2YH8RIn7YAokXWic2uyi857jlNLGgEX
```

### 3. Permissions Investigation
- Checked user group memberships
- Found `1Password-BrowserSupport` binary requires `onepassword` group
- Added user to `onepassword` group: `sudo usermod -a -G onepassword pbjorklund`
- This didn't resolve the issue

### 4. Research Phase
- Found GitHub issue NixOS/nixpkgs#258139 with identical symptoms
- Confirmed CLI tries to connect to `/run/user/1000/1Password-BrowserSupport.sock`
- But actual debug showed it was trying different communication path

### 5. Terminal Environment Speculation
- Considered if alacritty vs other terminals could cause issues
- Investigated if running through opencode vs direct terminal mattered
- These were red herrings

### 6. Version Discovery (ROOT CAUSE)
Found two CLI installations:
```bash
$ which -a op
/usr/local/bin/op
/usr/bin/op

$ /usr/local/bin/op --version
2.32.0

$ /usr/bin/op --version  
2.31.1

$ pacman -Q 1password
1password 8.11.6-27
```

## Root Cause
**Missing group membership for CLI integration:**

The user was not in the `onepassword` group, which is required for CLI integration with the desktop app.

**The fix that worked:**
```bash
sudo usermod -a -G onepassword pbjorklund
# Then logout/login or reboot for group membership to take effect
```

**Evidence this was the real fix:**
- After adding to `onepassword` group, `/usr/bin/op` worked immediately
- The version difference was a red herring - both versions would have failed without proper group membership
- The CLI shows `NM response: Success` after group membership was added

**Why group membership matters:**
The 1Password CLI uses the setgid bit to run with `onepassword-cli` group privileges, but it also needs the user to be in the `onepassword` group to communicate with the desktop app's IPC mechanisms.

## Solution
**Add user to the `onepassword` group:**
```bash
sudo usermod -a -G onepassword pbjorklund
```

**Then logout/login or reboot** for group membership to take effect.

**Verify working state:**
```bash
$ groups | grep onepassword
pbjorklund docker wheel onepassword-cli onepassword

$ OP_BIOMETRIC_UNLOCK_ENABLED=true op vault ls --debug
8:05AM | DEBUG | Session delegation enabled
8:05AM | DEBUG | NM request: NmRequestAccounts
8:05AM | DEBUG | NM response: Success  # ← This means it's working!
```

## Key Learnings

### 1Password Socket Architecture
- **SSH Agent:** `~/.1password/agent.sock` - for SSH key operations
- **Browser Support:** `/run/user/1000/1Password-BrowserSupport.sock` - for browser extension
- **CLI Integration:** Abstract socket `@/tmp/1Password-1000/...` - for CLI app integration

### Version Compatibility
- Desktop app and CLI versions must be compatible
- Manual CLI installations can conflict with system packages
- Always prefer system package manager versions for compatibility

### Group Permissions & Security Model
- **Browser support:** Requires `onepassword` group membership
- **CLI integration:** Requires BOTH `onepassword` AND `onepassword-cli` group membership + setgid binary
- **Critical insight:** User must be in `onepassword` group for desktop app IPC access
- The setgid bit on `/usr/bin/op` provides `onepassword-cli` group privileges, but user still needs `onepassword` group for desktop communication

### Browser Integration Setup
Our custom browser setup in `/etc/1password/custom_allowed_browsers`:
```bash
# File: /etc/1password/custom_allowed_browsers
zen-bin
```
This works because we added zen browser support during setup.

## Prevention
1. **Ensure proper group membership** during 1Password installation
2. **Check user is in both required groups:** `onepassword` and `onepassword-cli`
3. **Remember to logout/login** after group changes
4. **Verify group membership before troubleshooting** other issues

## Working Configuration
- **Desktop App:** 1password 8.11.6-27 (from AUR)
- **CLI:** 1password-cli 2.31.1-1 (from AUR)  
- **User Groups:** `onepassword` and `onepassword-cli`
- **CLI Integration:** Enabled in Settings → Developer
- **Browser Integration:** zen-bin allowed in `/etc/1password/custom_allowed_browsers`

## Commands for Future Reference
```bash
# Check for multiple CLI installations
which -a op

# Check versions
op --version
pacman -Q 1password 1password-cli

# Check binary permissions (CRITICAL)
ls -la /usr/bin/op
# Should show: -rwxr-sr-x 1 root onepassword-cli

# Check group membership
groups | grep onepassword
getent group onepassword-cli

# Check sockets
ss -lx | grep -i 1password
lsof -U | grep -i 1password

# Test CLI integration
OP_BIOMETRIC_UNLOCK_ENABLED=true op vault ls --debug
```