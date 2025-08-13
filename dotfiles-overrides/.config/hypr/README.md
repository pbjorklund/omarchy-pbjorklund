# Hyprland Configuration

Hyprland window manager configuration for development environments.

## Features

- **Native lid switch handling**: Simple display disable/enable on lid events
- **Idle management**: Screen lock and suspend via hypridle
- **Multi-monitor support**: Automatic display configuration
- **Power management**: Battery and AC-aware timeouts

## Behavior

### Lid Events

- **Lid Closed**: Disables laptop display (`eDP-1`)
- **Lid Opened**: Re-enables laptop display with preferred settings

### Idle Management

Handled by hypridle with different timeouts for battery vs AC power.

## Files

- **`hyprland.conf`**: Main configuration with native lid bindings
- **`hyprlock.conf`**: Screen locker configuration
- **`hypridle.conf`**: Idle timeout management

## Prerequisites

- `hyprctl` - Hyprland control utility
- `hyprlock` - Screen locker for Hyprland
- `hypridle` - Idle management daemon

## Installation

### Install Required Packages

```bash
$ sudo dnf install -y hyprlock hypridle
```

The configuration is automatically active when using this dotfiles setup.

## Usage

### Manual Screen Lock

- **Super+L**: Lock screen immediately using hyprlock

### Automatic Behavior

Lid events and idle timeouts are handled automatically by Hyprland's native bindings and hypridle.

## Troubleshooting

### Check Connected Monitors

```bash
$ hyprctl monitors
```

## Supported Hardware

- ThinkPad X1 Carbon Gen 11
- Any laptop with `eDP-1` internal display
- External monitors via USB-C dock or direct connection
