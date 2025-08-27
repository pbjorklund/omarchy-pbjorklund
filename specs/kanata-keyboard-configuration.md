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

This section defines which keys on the physical keyboard you want kanata to intercept. You have two approaches:

**Approach 1: Minimal - Only Keys You're Changing (Recommended)**
- Only include keys you're actually modifying
- All other keys pass through unchanged automatically
- Results in cleaner, more maintainable configuration

**Approach 2: Complete - Full Keyboard Layout**  
- Define every key on the keyboard
- Gives you complete control over all keys
- Requires explicitly passing through unchanged keys

**Important Layout Rules (Both Approaches)**:
- Keys must be positioned exactly as they appear on the physical keyboard
- Rows matter - keys on different physical rows must be on different lines
- Each row in `defsrc` represents a physical row on your keyboard

**Minimal Example (Current Configuration):**
```lisp
(defsrc
  caps    ; Row 1: caps lock key
  [       ; Row 2: left bracket
  ;    '  ; Row 3: semicolon and quote (same physical row)
  ralt    ; Row 4: right alt
)
```

**Complete Example:**
```lisp
(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]
  caps a    s    d    f    g    h    j    k    l    ;    '    \    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet menu rctl
)
```

#### 3. deflayer - Layer Definitions

Each layer must match the `defsrc` layout exactly - same number of keys in same positions. The behavior differs between approaches:

**Minimal Approach - Only Remapped Keys**

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
  _       ; _ means "transparent" - use base layer action (lctl)
  @aa     ; [ becomes å/Å tap-hold
  @oo  @ae ; ; becomes ö/Ö, ' becomes ä/Ä
  _       ; ralt transparent (still acts as layer switch)
)
```

**Complete Approach - Full Keyboard**

**Base layer:**
```lisp
(deflayer base
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]
  lctl a    s    d    f    g    h    j    k    l    ;    '    \    ret  ; caps → lctl
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            @l2 rmet menu rctl        ; ralt → @l2
)
```

**Layer 2:**
```lisp
(deflayer l2
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    @aa   _      ; [ → å/Å
  _    _    _    _    _    _    _    _    _    _    @oo  @ae   _    _ ; ; → ö/Ö, ' → ä/Ä
  _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _              _              _    _    _    _
)
```

### Key Differences Between Approaches

**Minimal Approach:**
- `_` in layer 2 = transparent to base layer action
- Undefined keys = pass through unchanged (kanata doesn't intercept them)
- Cleaner, more maintainable

**Complete Approach:**  
- `_` in layer 2 = transparent to base layer action
- All keys explicitly defined = kanata controls everything
- Unchanged keys must be written as themselves (e.g., `q` stays `q`, not `_`)
- More control but more verbose

**Understanding `_` (Transparency):**
- `_` means "use the action from the layer below"
- In layer 2 with minimal approach: `_` uses the base layer action
- In layer 2 with complete approach: `_` uses the base layer action
- `_` is NOT used in base layer for "unchanged" keys - those are written as themselves

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

## Configuration Examples

### Adding More Keys to Remap

The key principle is that **position in `defsrc` must match position in every `deflayer`**. Here's how to add the Tab key as an example:

#### Current Configuration
```lisp
(defsrc
  caps    ; Row 1: caps lock
  [       ; Row 2: left bracket  
  ;    '  ; Row 3: semicolon and quote (same physical row)
  ralt    ; Row 4: right alt
)
```

#### Adding Tab Key

Since Tab and `[` are on the same physical keyboard row, they must be on the same line in `defsrc`:

```lisp
(defsrc
  caps         ; Row 1: caps lock
  tab  [       ; Row 2: tab and left bracket (same physical row)
  ;    '       ; Row 3: semicolon and quote  
  ralt         ; Row 4: right alt
)
```

**Critical Rule**: Every `deflayer` must have the exact same structure as `defsrc` - same number of keys in identical positions.

#### Example 1: Tab → Ctrl in Base Layer

If you want Tab to become Left Ctrl in the base layer:

```lisp
(deflayer base
  lctl         ; caps → left control
  lctl [       ; tab → left control, [ stays [
  ;    '       ; semicolon and quote unchanged
  @l2          ; ralt → layer switch
)

(deflayer l2  
  _            ; caps transparent (acts as lctl from base)
  _    @aa     ; tab transparent (acts as lctl), [ → å/Å
  @oo  @ae     ; ; → ö/Ö, ' → ä/Ä
  _            ; ralt transparent (still layer switch)
)
```

**Result**: 
- Tab always acts as Left Ctrl
- Base layer: Tab=Ctrl, [=[
- Layer 2: Tab=Ctrl, [=å/Å

#### Example 2: Tab Stays Tab in Base, Becomes Ctrl in Layer 2

```lisp
(deflayer base
  lctl         ; caps → left control  
  tab  [       ; tab stays tab, [ stays [
  ;    '       ; semicolon and quote unchanged
  @l2          ; ralt → layer switch
)

(deflayer l2
  _            ; caps transparent (acts as lctl from base)
  lctl @aa     ; tab → left control, [ → å/Å  
  @oo  @ae     ; ; → ö/Ö, ' → ä/Ä
  _            ; ralt transparent (still layer switch)
)
```

**Result**:
- Base layer: Tab=Tab, [=[  
- Layer 2: Tab=Ctrl, [=å/Å (when holding Right Alt)

#### Example 3: Adding Multiple Keys on Same Row

If you wanted to add Q, W, E along with Tab and [, since they're all on the same physical row:

```lisp
(defsrc
  caps              ; Row 1: caps lock
  q  w  e  tab  [   ; Row 2: all keys on same physical row
  ;    '            ; Row 3: semicolon and quote
  ralt              ; Row 4: right alt  
)

(deflayer base
  lctl              ; caps → left control
  q  w  e  lctl [   ; q,w,e unchanged, tab → ctrl, [ unchanged
  ;    '            ; semicolon and quote unchanged  
  @l2               ; ralt → layer switch
)

(deflayer l2
  _                 ; caps transparent
  _  _  _  _    @aa ; q,w,e,tab transparent, [ → å/Å
  @oo  @ae          ; ; → ö/Ö, ' → ä/Ä
  _                 ; ralt transparent
)
```

### Key Position Rules

1. **Physical Layout Matters**: Keys must be positioned in `defsrc` exactly as they appear on your physical keyboard
   
2. **Row Consistency**: All keys on the same physical row must be on the same line in `defsrc`

3. **Layer Matching**: Every `deflayer` must have identical structure to `defsrc`:
   - Same number of rows
   - Same number of keys per row  
   - Keys in identical positions

4. **Transparency (`_`) Rules**:
   - **In non-base layers**: `_` means "use action from layer below" 
   - **In base layer**: Don't use `_` - write actual key names or aliases
   - **Minimal approach**: Undefined keys pass through unchanged automatically
   - **Complete approach**: All keys must be explicitly defined

5. **Approach Selection**:
   - **Minimal**: Only define keys you want to modify (recommended for simple configs)
   - **Complete**: Define entire keyboard layout (better for complex remapping)

### Understanding Key Passthrough

**Minimal Approach:**
```lisp
(defsrc
  caps
  [
)

(deflayer base
  lctl    ; caps becomes left control
  [       ; [ stays as [
)
```
- Keys not in `defsrc` (like `q`, `w`, `a`, etc.) automatically pass through unchanged
- Kanata doesn't intercept them at all

**Complete Approach:**
```lisp
(defsrc  
  caps a   b
  [    q   w
)

(deflayer base
  lctl a   b     ; caps→lctl, a and b stay themselves  
  [    q   w     ; All keys explicitly defined as themselves or new actions
)
```
- Every key in `defsrc` must be handled in every `deflayer`
- Unchanged keys are written as themselves (`a` stays `a`)
- Never use `_` in base layer for "unchanged" keys

### Common Mistakes to Avoid

❌ **Wrong - Using `_` in base layer for unchanged keys:**
```lisp
(deflayer base
  lctl _   _     ; Wrong: base layer should never have _
  [    _   _     ; Wrong: write actual key names instead
)
```

✅ **Correct - Explicit key names in base layer:**
```lisp
(deflayer base  
  lctl a   b     ; Correct: unchanged keys written as themselves
  [    q   w     ; Correct: explicit key definitions
)
```

❌ **Wrong - Keys on different lines when they're on same physical row:**
```lisp
(defsrc
  tab    ; Wrong: tab on separate line
  [      ; Wrong: [ on separate line when they're same physical row
)
```

❌ **Wrong - Layer doesn't match defsrc structure:**
```lisp
(defsrc
  tab  [
  ;    '
)

(deflayer base
  lctl     ; Wrong: first row needs 2 keys but only has 1
  ;    '   ; Wrong: this creates misaligned structure
)
```

✅ **Correct - Matching structure:**
```lisp
(defsrc
  tab  [   ; Same physical row
  ;    '   ; Same physical row  
)

(deflayer base
  lctl [   ; Must have same number of keys per row
  ;    '   ; Must match defsrc exactly
)
```

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
