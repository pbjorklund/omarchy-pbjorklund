# Omarchy Keyring Auto-unlock Investigation

**Date:** August 21, 2025  
**Issue:** "The login keyring did not get unlocked when you logged in" error  
**Status:** Root cause identified, community solution available  

## Summary

This document details a comprehensive investigation into keyring auto-unlock issues in omarchy's autologin system. The fundamental problem is that omarchy's seamless autologin bypasses traditional PAM authentication flows that would normally unlock keyrings automatically.

## Problem Description

### Initial Symptoms
- Pop-up message: "The login keyring did not get unlocked when you logged in"
- Empty `~/.local/share/keyrings/` directory on fresh installations
- 1Password unable to save MFA tokens
- Applications expecting keyring services failing to store secrets
- Manual keyring creation doesn't auto-unlock on subsequent logins

### User Impact
- Breaks password manager integration (1Password, etc.)
- Prevents automatic storage of authentication tokens
- Requires manual keyring unlock after each login
- Creates security prompts for unsecured secret storage

## Root Cause Analysis

### Omarchy's Autologin Architecture
Omarchy uses a custom autologin system instead of traditional display managers:

```
systemd service: omarchy-seamless-login.service
├── ExecStart: /usr/local/bin/seamless-login uwsm start -- hyprland.desktop
├── PAMName: login
├── User: pbjorklund
└── TTY: /dev/tty1
```

The `seamless-login` binary handles the login process without traditional password authentication.

### PAM Configuration Issues
The core issue is in `/etc/pam.d/system-login` which lacks keyring integration:

**Missing from PAM config:**
```bash
auth       optional   pam_gnome_keyring.so
password   optional   pam_gnome_keyring.so use_authtok  
session    optional   pam_gnome_keyring.so auto_start
```

### Authentication Flow Breakdown
1. **Normal Login:** User password → PAM → Keyring unlocked with same password
2. **Omarchy Autologin:** No password entry → PAM auth bypassed → Keyring never unlocked
3. **LUKS vs Login:** User enters LUKS password at boot, but no login password for keyring

## Investigation Timeline

### Initial Attempts
1. **Manual keyring creation:** Created keyring in Seahorse, set password to LUKS password
2. **Keyring daemon restart:** `pkill gnome-keyring-daemon && gnome-keyring-daemon --start`
3. **Directory verification:** Confirmed keyring files exist but aren't auto-unlocking

### PAM Modification Attempt
Added keyring modules to `/etc/pam.d/system-login`:
```bash
auth       optional   pam_gnome_keyring.so
password   optional   pam_gnome_keyring.so use_authtok
session    optional   pam_gnome_keyring.so auto_start
```

**Result:** No improvement - autologin still bypasses PAM authentication phase

### Discovery of Side Effects
During investigation, accidentally changed system keymap from `us` to `us-acentos`:
- **Effect:** LUKS password entry used Swedish keyboard layout
- **Location:** `/etc/vconsole.conf` - `KEYMAP=us-acentos`
- **Fix:** Changed back to `KEYMAP=us`

### Research into Omarchy Issues
Found related GitHub issues in basecamp/omarchy:
- **Issue #352:** "Gnome-keyring not creating default keyvault, 1Password MFA issues"
- **PR #919:** VSCode keyring integration fix
- **PR #631:** Replace gnome-keyring with pass/pass-secret-service

## Technical Analysis

### Keyring Initialization Process
**Normal Flow:**
```
Login → PAM auth → pam_gnome_keyring.so → Create/unlock keyring → Apps access keyring
```

**Omarchy Flow:**
```
LUKS unlock → seamless-login → Hyprland start → No keyring initialization → Apps fail
```

### File System Investigation
**Keyring locations checked:**
- `~/.local/share/keyrings/` - Primary keyring storage
- `/etc/pam.d/system-login` - PAM configuration for login
- `/etc/pam.d/system-auth` - Base authentication config

**Key findings:**
- PAM modules exist: `/usr/lib/security/pam_gnome_keyring.so`
- Keyring daemon runs: `gnome-keyring-daemon`
- D-Bus services available for keyring access

### Autologin Service Analysis
**Service file:** `/etc/systemd/system/omarchy-seamless-login.service`
```ini
[Unit]
Description=Omarchy Seamless Auto-Login
Conflicts=getty@tty1.service
After=systemd-user-sessions.service getty@tty1.service

[Service]
Type=simple
ExecStart=/usr/local/bin/seamless-login uwsm start -- hyprland.desktop
User=pbjorklund
TTYPath=/dev/tty1
PAMName=login
```

**Critical insight:** `PAMName=login` should trigger PAM, but seamless-login binary may bypass authentication phases.

## Community Solutions

### Pass + Pass-Secret-Service (PR #631)
The omarchy community developed a comprehensive solution replacing gnome-keyring:

**Components:**
1. **pass** - Command-line password manager using GPG encryption
2. **pass-secret-service** - D-Bus interface compatibility layer
3. **Auto-generated GPG key** - No password required for seamless operation

**Implementation highlights:**
```bash
# Generate GPG key without password
gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Name-Real: Omarchy
Name-Email: omarchy@keyring.local
Expire-Date: 0
EOF

# Initialize pass store
pass init $GPG_KEY_ID

# Install pass-secret-service for D-Bus compatibility
yay -S pass-secret-service
```

**Advantages:**
- No dependency on login passwords
- Works seamlessly with autologin
- Provides same D-Bus interface apps expect
- Stores secrets encrypted but auto-accessible

### VSCode Integration (PR #919)
Separate issue with VSCode not using gnome-keyring on Hyprland:

**Solution:** Configure VSCode to use gnome-libsecret
```json
// ~/.vscode/argv.json
{
  "password-store": "gnome-libsecret"
}
```

## Attempted Solutions

### 1. PAM Configuration Modification
**Approach:** Add keyring modules to system-login PAM config
**Result:** Failed - autologin bypasses PAM auth phase
**Files modified:** `/etc/pam.d/system-login`
**Reverted:** Yes, using `pacman -S --noconfirm pambase`

### 2. Manual Keyring with LUKS Password
**Approach:** Create keyring manually, set password to LUKS password
**Result:** Partial success - keyring exists but doesn't auto-unlock
**Method:** Used Seahorse GUI to create "login" keyring

### 3. Passwordless Keyring
**Approach:** Create keyring with no password
**Result:** Success - no unlock prompt, but potentially less secure
**Implementation:** Seahorse GUI, empty password field

### 4. Keyring Daemon Restart
**Approach:** Restart gnome-keyring-daemon to reinitialize
**Commands used:**
```bash
pkill -f gnome-keyring-daemon
gnome-keyring-daemon --start --daemonize --components=secrets
```
**Result:** Temporary, doesn't persist across reboots

## Files and Configurations

### Key Configuration Files
```
/etc/pam.d/system-login          # PAM config for login process
/etc/pam.d/system-auth           # Base PAM authentication  
/etc/vconsole.conf               # Console keyboard layout
/etc/systemd/system/omarchy-seamless-login.service  # Autologin service
~/.local/share/keyrings/         # User keyring storage
/usr/lib/security/pam_gnome_keyring.so  # PAM keyring module
```

### Original vs Modified States
**vconsole.conf changes:**
```bash
# Before (problematic)
KEYMAP=us-acentos

# After (fixed)  
KEYMAP=us
```

**PAM modifications (reverted):**
```bash
# Added but removed:
auth       optional   pam_gnome_keyring.so
password   optional   pam_gnome_keyring.so use_authtok
session    optional   pam_gnome_keyring.so auto_start
```

## Lessons Learned

### Technical Insights
1. **Autologin fundamentally incompatible with traditional keyring unlock**
2. **PAM modifications insufficient when auth phase is bypassed**
3. **Alternative keyring systems can provide better autologin compatibility**
4. **D-Bus interface compatibility crucial for app integration**

### Investigation Process
1. **System-level changes can have unexpected side effects** (keymap issue)
2. **Community solutions often more comprehensive than quick fixes**
3. **Understanding the full authentication flow essential**
4. **Multiple approaches needed for complex system integration issues**

### Omarchy Architecture
1. **Custom autologin system creates unique challenges**
2. **Traditional Linux desktop solutions may not apply directly**
3. **Security vs convenience tradeoffs in seamless experience**

## Recommendations

### Immediate Solution
For users experiencing this issue now:
1. Create passwordless keyring via Seahorse
2. Accept security tradeoff for convenience
3. Monitor for official omarchy solution

### Long-term Solution
Implement PR #631 approach in omarchy:
1. Replace gnome-keyring with pass + pass-secret-service
2. Auto-generate GPG key during installation
3. Provide migration path for existing users
4. Maintain D-Bus compatibility for applications

### Alternative Approaches
1. **Display Manager Integration:** Add optional DM support for users wanting traditional login
2. **Hybrid Approach:** Allow user choice between autologin and traditional login
3. **Enhanced PAM Integration:** Modify seamless-login to properly trigger PAM keyring modules

## Related Issues and PRs

### GitHub basecamp/omarchy References
- **Issue #352:** Gnome-keyring not creating default keyvault, 1Password MFA issues
- **PR #631:** Replace gnome-keyring with pass/pass-secret-service (24 comments, active discussion)
- **PR #919:** FIX: Add VSCode gnome-keyring integration for Hyprland
- **Issue #667:** Possible to unlock keyring with fingerprint / fido2?

### Community Validation
Multiple users confirmed:
- Fresh VM installations show empty keyring directories
- 1Password MFA token storage fails
- Manual keyring creation with auto-unlock challenges
- Pass-based solution works reliably

## Security Considerations

### Current Passwordless Approach
**Pros:**
- No user interaction required
- Seamless user experience
- Apps can store secrets

**Cons:**
- Secrets accessible without authentication
- Relies solely on disk encryption
- Potential privilege escalation risk

### Pass-based Solution
**Pros:**
- GPG encryption of secrets
- No dependency on login passwords
- Proven command-line tool ecosystem

**Cons:**
- Additional complexity
- GPG key management requirements
- Different from standard Linux desktop patterns

## Conclusion

The keyring auto-unlock issue in omarchy stems from fundamental architectural decisions around seamless autologin. Traditional PAM-based keyring solutions are incompatible with bypassing password authentication. The community has developed a robust alternative using pass + pass-secret-service that maintains security while providing the seamless experience omarchy aims for.

The investigation revealed the complexity of integrating security tools with non-standard authentication flows and highlighted the importance of understanding the complete system architecture when troubleshooting integration issues.

**Status:** Issue understood, community solution available, awaiting integration into omarchy mainline.