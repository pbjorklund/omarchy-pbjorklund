#!/bin/bash
#
# Kanata keyboard device detection and USB controller finder
# Detects keyboard devices for kanata and finds USB controllers for wake-on-USB
#

set -e

detect_keyboards_for_kanata() {
    echo "=== Kanata Keyboard Device Detection ==="
    
    # Check for keyboards in /proc/bus/input/devices
    if ! grep -q keyboard /proc/bus/input/devices 2>/dev/null; then
        echo "✗ No keyboard devices found in /proc/bus/input/devices"
        return 1
    fi
    
    echo "✓ Found keyboard devices:"
    grep -A 5 -B 1 keyboard /proc/bus/input/devices | grep "Name\|Handlers" | while read line; do
        echo "  $line"
    done
    
    # Check specific device paths that kanata will try
    local found_device=false
    
    # ThinkPad/laptop built-in keyboard path
    if [ -e "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ]; then
        echo "✓ Found built-in keyboard: /dev/input/by-path/platform-i8042-serio-0-event-kbd"
        found_device=true
    fi
    
    # Generic event device (fallback)
    if [ -e "/dev/input/event3" ]; then
        echo "✓ Found generic keyboard: /dev/input/event3"
        found_device=true
    fi
    
    # USB keyboards
    if ls /dev/input/by-id/usb-*-kbd 2>/dev/null || ls /dev/input/by-id/usb-*-keyboard 2>/dev/null; then
        echo "✓ Found USB keyboards:"
        ls /dev/input/by-id/usb-*-kbd /dev/input/by-id/usb-*-keyboard 2>/dev/null || true
        found_device=true
    fi
    
    if [ "$found_device" = false ]; then
        echo "✗ No accessible keyboard devices found for kanata"
        echo "Available event devices:"
        ls -la /dev/input/event* | head -5
        return 1
    fi
    
    echo "✓ Keyboard devices available for kanata"
    echo
}

find_usb_keyboards_and_controllers() {
    echo "=== USB Keyboard Detection ==="
    
    # Find keyboard device
    keyboard_device=""
    for device in /sys/bus/usb/devices/*/; do
        if [ -f "$device/product" ]; then
            product=$(cat "$device/product" 2>/dev/null || echo "")
            if echo "$product" | grep -qi "keyboard"; then
                device_id=$(basename "$device")
                echo "Found keyboard: $device_id ($product)"
                keyboard_device="$device_id"
                break
            fi
        fi
    done
    
    if [ -z "$keyboard_device" ]; then
        echo "No USB keyboard found!"
        echo
        return 0
    fi
    
    # Find the real path and controller
    real_path=$(readlink -f "/sys/bus/usb/devices/$keyboard_device")
    echo "Real path: $real_path"
    
    # Extract PCI device
    pci_device=$(echo "$real_path" | grep -o "0000:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]\.[0-9]" | head -1)
    echo "PCI device: $pci_device"
    
    # Find corresponding ACPI wake device
    if [ -n "$pci_device" ]; then
        acpi_device=$(grep "$pci_device" /proc/acpi/wakeup | awk '{print $1}')
        echo "ACPI wake device: $acpi_device"
        
        if [ -n "$acpi_device" ]; then
            status=$(grep "$acpi_device" /proc/acpi/wakeup | awk '{print $3}')
            echo "Current status: $status"
            
            echo ""
            echo "=== Recommended Commands ==="
            echo "Enable keyboard wake: echo enabled | sudo tee /sys/bus/usb/devices/$keyboard_device/power/wakeup"
            echo "Enable USB controller: sudo bash -c 'echo $acpi_device > /proc/acpi/wakeup'"
        fi
    fi
    echo
}

check_kanata_permissions() {
    echo "=== Kanata Permissions ==="
    
    # Check uinput group membership
    if ! groups | grep -q uinput; then
        echo "✗ User not in uinput group. Run: sudo usermod -a -G uinput $USER"
        return 1
    fi
    
    echo "✓ User in uinput group"
    
    # Check uinput device
    if [ ! -e "/dev/uinput" ]; then
        echo "✗ /dev/uinput not found. Load uinput module: sudo modprobe uinput"
        return 1
    fi
    
    if [ ! -w "/dev/uinput" ]; then
        echo "✗ No write access to /dev/uinput. Check group membership and relogin."
        return 1
    fi
    
    echo "✓ uinput device accessible"
    echo
}

main() {
    detect_keyboards_for_kanata || exit 1
    find_usb_keyboards_and_controllers
    check_kanata_permissions || exit 1
    echo "✓ All checks completed"
}

# Allow sourcing for use in other scripts
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi