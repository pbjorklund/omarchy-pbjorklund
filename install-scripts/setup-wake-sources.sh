#!/bin/bash
set -e

echo "Configuring wake sources for suspend..."

# Disable all USB device wake sources first
echo "Disabling all USB device wake sources..."
for device in /sys/bus/usb/devices/*/power/wakeup; do
    if [ -w "$device" ] || sudo test -w "$device"; then
        echo disabled | sudo tee "$device" >/dev/null 2>&1 || true
    fi
done

# Find keyboard device dynamically
echo "Finding USB keyboard..."
keyboard_device=""
for device in /sys/bus/usb/devices/*/; do
    if [ -f "$device/product" ]; then
        product=$(cat "$device/product" 2>/dev/null || echo "")
        if echo "$product" | grep -qi "keyboard"; then
            keyboard_device=$(basename "$device")
            echo "Found keyboard: $keyboard_device ($product)"
            break
        fi
    fi
done

if [ -z "$keyboard_device" ]; then
    echo "Warning: No USB keyboard found!"
    echo "This is normal when ThinkPad is not docked or using built-in keyboard."
    echo "Built-in keyboard wake sources are handled by firmware."
    
    # Still configure basic USB wake settings for when external devices are connected
    echo "Configuring basic USB wake settings..."
    
    # Enable common USB controllers that might be needed later
    all_usb_controllers=$(grep -E "^(XHC|XH)[0-9]+" /proc/acpi/wakeup | awk '{print $1}')
    for controller in $all_usb_controllers; do
        if grep -q "^$controller.*disabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "Enabling $controller for future USB devices"
            echo "$controller" | sudo tee /proc/acpi/wakeup >/dev/null
        fi
    done
    
    echo "Wake source configuration complete (no external keyboard)."
    exit 0
fi

# Enable keyboard wake source
echo "Enabling keyboard wake source..."
echo enabled | sudo tee "/sys/bus/usb/devices/$keyboard_device/power/wakeup" >/dev/null 2>&1 || true

# Find keyboard's USB controllers dynamically
real_path=$(readlink -f "/sys/bus/usb/devices/$keyboard_device")
echo "Keyboard path: $real_path"

# Extract all PCI devices in the path and find corresponding ACPI wake devices
pci_devices=$(echo "$real_path" | grep -o "0000:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]\.[0-9]" | sort -u)
acpi_devices=""

for pci_device in $pci_devices; do
    acpi_device=$(grep "$pci_device" /proc/acpi/wakeup 2>/dev/null | awk '{print $1}' || true)
    if [ -n "$acpi_device" ]; then
        acpi_devices="$acpi_devices $acpi_device"
        echo "Found ACPI device: $acpi_device ($pci_device)"
    fi
done

# Enable required ACPI wake devices for keyboard
if [ -n "$acpi_devices" ]; then
    echo "Enabling ACPI wake devices for keyboard..."
    for acpi_device in $acpi_devices; do
        if grep -q "^$acpi_device.*disabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "Enabling $acpi_device"
            echo "$acpi_device" | sudo tee /proc/acpi/wakeup >/dev/null
        fi
    done
fi

# Disable all other USB controllers to prevent unwanted wake
echo "Disabling other USB controllers..."
all_usb_controllers=$(grep -E "^(XHC|XH)[0-9]+" /proc/acpi/wakeup | awk '{print $1}')
for controller in $all_usb_controllers; do
    # Skip if this controller is needed for keyboard
    if echo "$acpi_devices" | grep -q "$controller"; then
        continue
    fi
    if grep -q "^$controller.*enabled" /proc/acpi/wakeup 2>/dev/null; then
        echo "Disabling $controller"
        echo "$controller" | sudo tee /proc/acpi/wakeup >/dev/null
    fi
done

echo "Wake source configuration complete."
echo "Keyboard device: $keyboard_device"
echo "Keyboard wake status: $(cat "/sys/bus/usb/devices/$keyboard_device/power/wakeup" 2>/dev/null || echo "not found")"
echo "Enabled ACPI devices: $acpi_devices"
