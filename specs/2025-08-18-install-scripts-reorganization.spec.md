# Simple System Detection for ThinkPad vs Desktop

**Date:** August 18, 2025  
**Version:** 2.0  
**Goal:** Make install.sh detect ThinkPad vs desktop and run appropriate scripts

## The Problem
- AMD drivers install on ThinkPad (shouldn't)
- Screen recording fails on ThinkPad (missing Intel VAAPI)
- DisplayLink installs on desktop (shouldn't)

## The Solution

### 1. Add simple detection to utils.sh
```bash
is_thinkpad() {
    ls /sys/class/power_supply/BAT* &>/dev/null
}
```

### 2. Update install.sh execution list
Make it crystal clear which scripts run where:

```bash
declare -a INSTALL_STEPS=(
  "setup-directories.sh|Development directories setup|ALL"
  "install-bin-scripts.sh|Custom scripts installation|ALL"
  "install-stow.sh|Package managers installation|ALL"
  "link-dotfiles.sh|Personal dotfiles deployment|ALL"
  "install-node-lts.sh|Node.js LTS installation|ALL"
  "install-terminal-tools.sh|Terminal tools installation|ALL"
  "install-intel-vaapi.sh|Intel VAAPI for screen recording|THINKPAD"
  "install-amd-drivers.sh|AMD graphics drivers setup|DESKTOP"
  "install-displaylink.sh|DisplayLink drivers setup|THINKPAD"
  "install-zen-browser.sh|Zen browser setup|ALL"
  "install-screen-recorder.sh|Screen recorder setup|ALL"
  "install-opencode.sh|OpenCode setup|ALL"
  "install-claude-code.sh|Claude Code setup|ALL"
  "install-zotero.sh|Zotero installation|ALL"
  "install-plexamp.sh|Plexamp installation|ALL"
  "install-tailscale.sh|Tailscale installation|ALL"
  "install-pbp.sh|Personal project setup|ALL"
  "copy-desktop-files.sh|Desktop files copying|ALL"
  "setup-desktop-suspend.sh|Desktop suspend and hypridle setup|ALL"
  "install-iac-tools.sh|Infrastructure as Code tools|ALL"
  "uninstall-typora.sh|Typora removal|ALL"
  "uninstall-spotify.sh|Spotify removal|ALL"
  "configure-audio.sh|USB Audio configuration|ALL"
  "setup-mouse.sh|Gaming mouse configuration|ALL"
)

for step in "${INSTALL_STEPS[@]}"; do
  IFS='|' read -r script_name description system <<< "$step"
  
  case "$system" in
    "ALL")
      run_installation_step "$script_name" "$description"
      ;;
    "THINKPAD")
      if is_thinkpad; then
        run_installation_step "$script_name" "$description"
      else
        show_skip "$description (desktop detected)"
      fi
      ;;
    "DESKTOP")
      if is_thinkpad; then
        show_skip "$description (ThinkPad detected)"
      else
        run_installation_step "$script_name" "$description"
      fi
      ;;
  esac
done
```

### 3. Create install-intel-vaapi.sh
```bash
#!/bin/bash
set -e
source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_package "libva-utils" "Intel VAAPI utilities"
install_package "intel-media-driver" "Intel media driver"
```

## Files to Change
1. `utils.sh` - Add `is_thinkpad()` function
2. `install.sh` - Update INSTALL_STEPS array and execution logic  
3. `install-scripts/install-intel-vaapi.sh` - New script for ThinkPad
4. `install-scripts/install-amd-drivers.sh` - Remove internal laptop detection
5. `install-scripts/install-displaylink.sh` - Remove internal laptop detection

## Result
- Look at install.sh and immediately see: script name | description | which systems
- ThinkPad gets Intel VAAPI + DisplayLink, skips AMD
- Desktop gets AMD drivers, skips ThinkPad stuff
- Everything else runs on both

Simple, clear, done.
```

---

**Implementation Status:** Ready for Implementation  
**Testing Required:** Both ThinkPad and AMD Desktop systems  
**Breaking Changes:** None - all existing functionality preserved  
**Rollback Plan:** Git revert to restore flat directory structure if needed  
**Next Steps:** Execute specification using AI agents or development team