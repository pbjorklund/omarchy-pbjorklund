#!/bin/bash

# Find keyboard device and its USB controller
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
    exit 1
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