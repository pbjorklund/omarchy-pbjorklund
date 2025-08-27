# Kanata Keyboard Configuration Documentation

## Overview

Kanata is a cross-platform software-based keyboard remapping tool that allows for advanced keyboard customization. Our configuration provides:

- **Caps Lock → Ctrl**: Caps lock becomes a control key
- **Right Alt → Layer Switch**: Hold right alt to access Swedish characters
- **Swedish Character Support**: Type å, ö, ä on US keyboard layout

## Installation & Setup

### Prerequisites

The installation is handled by `install-scripts/install-kanata.sh` which:

1. **Installs packages**:
   - `kanata-git` (AUR) - provides cmd support for external commands
   - `wtype` - handles Wayland text input

2. **User permissions**:
   - Adds user to `input` and `uinput` groups
   - Creates proper udev rules for `/dev/uinput` permissions

3. **Systemd service**:
   - Installs user service file
   - Enables kanata to start automatically

### Service Management

Kanata runs as a systemd user service:

```bash
# Start/stop service
systemctl --user start kanata
systemctl --user stop kanata
systemctl --user restart kanata

# Check status
systemctl --user status kanata

# View logs
journalctl --user -u kanata -n 50 -f
```

## Configuration Structure

### File Location

Configuration is stored in `dotfiles-overrides/.config/kanata/config.kbd` and deployed via GNU Stow.

### Basic Syntax

Kanata configuration consists of several sections:

#### 1. defcfg - Global Settings

```lisp
(defcfg
  process-unmapped-keys yes  ; Pass through unmodified keys
  danger-enable-cmd yes      ; Allow external commands (needed for wtype)
)
```

#### 2. defsrc - Source Layout Definition

This section defines which keys on the physical keyboard you want to modify. **Important**: 

- Only include keys you're actually changing
- Keys must be positioned exactly as they appear on the physical keyboard
- Rows matter - keys on different physical rows must be on different lines

```lisp
(defsrc
  caps    ; Top row: caps lock key
  [       ; Second row: left bracket
  ;    '  ; Third row: semicolon and quote (same physical row)
  ralt    ; Bottom row: right alt
)
```

#### 3. deflayer - Layer Definitions

Each layer must match the `defsrc` layout exactly - same number of keys in same positions.

**Base layer** (default):
```lisp
(deflayer base
  lctl    ; caps → left control
  [       ; [ stays as [
  ;    '  ; ; and ' stay unchanged  
  @l2     ; ralt → layer switch (defined in aliases)
)
```

**Layer 2** (Swedish characters):
```lisp
(deflayer l2
  _       ; _ means "transparent" - use base layer action
  @aa     ; [ becomes å/Å tap-hold
  @oo  @ae ; ; becomes ö/Ö, ' becomes ä/Ä
  _       ; ralt transparent (still acts as layer switch)
)
```

#### 4. defalias - Action Definitions

Aliases define complex behaviors:

```lisp
(defalias
  l2 (layer-while-held l2)                                    ; Layer switch
  aa (tap-hold 200 200 (cmd wtype å) (cmd wtype Å))         ; å/Å
  oo (tap-hold 200 200 (cmd wtype ö) (cmd wtype Ö))         ; ö/Ö  
  ae (tap-hold 200 200 (cmd wtype ä) (cmd wtype Ä))         ; ä/Ä
)
```

## How It Works

### Layer Switching

- **Right Alt** acts as a layer switch using `layer-while-held`
- Hold Right Alt + `[` = å (tap) or Å (hold 200ms+)
- Hold Right Alt + `;` = ö (tap) or Ö (hold 200ms+)
- Hold Right Alt + `'` = ä (tap) or Ä (hold 200ms+)

### Tap-Hold Behavior

The `tap-hold` syntax: `(tap-hold tap_timeout hold_timeout tap_action hold_action)`

- `tap_timeout`: 200ms - how long to wait for additional input before triggering tap
- `hold_timeout`: 200ms - minimum time key must be held to trigger hold action  
- Quick tap (under 200ms) = lowercase Swedish character
- Hold (200ms+) = uppercase Swedish character

### External Commands

We use `(cmd wtype X)` to output characters because:

- Kanata's built-in Unicode support is broken in our environment
- Direct character literals like `'å'` don't work reliably
- `wtype` handles Wayland text input correctly

## Known Limitations & Workarounds

### Unicode Issues
- **Problem**: Built-in Unicode functionality outputs `f6+carriagereturn` instead of actual characters
- **Solution**: Use external `wtype` commands

### Modifier Limitations
- **Problem**: Shift modifiers don't work with cmd actions: `S-(cmd wtype X)` fails
- **Problem**: `multi` with `S-` syntax doesn't work for uppercase variants
- **Solution**: Use separate `tap-hold` actions for each case (upper/lowercase)

### Why This Approach Works

1. **Minimal Configuration**: Only defines keys that actually change behavior
2. **Position Accuracy**: Respects physical keyboard layout in `defsrc`
3. **Layer Consistency**: Each layer has identical structure to `defsrc`
4. **Reliable Output**: Uses `wtype` for guaranteed character output
5. **User-Friendly**: Intuitive tap vs hold for case variants

## Usage Examples

- **Type å**: Hold Right Alt + tap `[` quickly
- **Type Å**: Hold Right Alt + hold `[` for 200ms+  
- **Type ö**: Hold Right Alt + tap `;` quickly
- **Type Ö**: Hold Right Alt + hold `;` for 200ms+
- **Type ä**: Hold Right Alt + tap `'` quickly
- **Type Ä**: Hold Right Alt + hold `'` for 200ms+
- **Use Ctrl**: Tap Caps Lock (now acts as Left Ctrl)

## Troubleshooting

### Service Not Starting
```bash
# Check service status
systemctl --user status kanata

# View recent logs
journalctl --user -u kanata -n 20

# Verify permissions
groups | grep -E "(input|uinput)"
```

### Characters Not Outputting
```bash
# Check if wtype is installed
which wtype

# Test wtype directly
wtype "å"

# Check kanata logs for cmd execution
journalctl --user -u kanata -f
```

### Configuration Syntax Errors
```bash
# Test configuration manually
kanata --cfg ~/.config/kanata/config.kbd --dry-run
```