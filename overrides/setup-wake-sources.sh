#!/bin/bash
set -e

echo "Setting up desktop suspend and wake sources..."

# Create suspend script that uses proper wake configuration
cat > /home/pbjorklund/omarchy-pbjorklund/bin/suspend-desktop.sh << 'EOF'
#!/bin/bash
set -e

# Disable all USB device wake sources first
for device in /sys/bus/usb/devices/*/power/wakeup; do
    if [ -w "$device" ] || sudo test -w "$device"; then
        echo disabled | sudo tee "$device" >/dev/null 2>&1 || true
    fi
done

# Find keyboard device dynamically
keyboard_device=""
for device in /sys/bus/usb/devices/*/; do
    if [ -f "$device/product" ]; then
        product=$(cat "$device/product" 2>/dev/null || echo "")
        if echo "$product" | grep -qi "keyboard"; then
            keyboard_device=$(basename "$device")
            break
        fi
    fi
done

if [ -n "$keyboard_device" ]; then
    # Enable keyboard wake source
    echo enabled | sudo tee "/sys/bus/usb/devices/$keyboard_device/power/wakeup" >/dev/null 2>&1 || true
    
    # Find keyboard's USB controllers and enable them
    real_path=$(readlink -f "/sys/bus/usb/devices/$keyboard_device")
    pci_devices=$(echo "$real_path" | grep -o "0000:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]\.[0-9]" | sort -u)
    
    for pci_device in $pci_devices; do
        acpi_device=$(grep "$pci_device" /proc/acpi/wakeup 2>/dev/null | awk '{print $1}' || true)
        if [ -n "$acpi_device" ] && grep -q "^$acpi_device.*disabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "$acpi_device" | sudo tee /proc/acpi/wakeup >/dev/null
        fi
    done
    
    # Disable other USB controllers
    all_usb_controllers=$(grep -E "^(XHC|XH)[0-9]+" /proc/acpi/wakeup | awk '{print $1}')
    for controller in $all_usb_controllers; do
        # Skip controllers needed for keyboard
        needed=false
        for pci_device in $pci_devices; do
            if grep -q "$controller.*$pci_device" /proc/acpi/wakeup 2>/dev/null; then
                needed=true
                break
            fi
        done
        if [ "$needed" = false ] && grep -q "^$controller.*enabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "$controller" | sudo tee /proc/acpi/wakeup >/dev/null
        fi
    done
fi

# Suspend the system
systemctl suspend
EOF

chmod +x /home/pbjorklund/omarchy-pbjorklund/bin/suspend-desktop.sh

# Update omarchy-menu to use our suspend script
if [ -f "$HOME/.local/share/omarchy/bin/omarchy-menu" ]; then
    echo "Updating omarchy-menu suspend command..."
    sed -i 's|\*Suspend\*) systemctl suspend ;;|*Suspend*) /home/pbjorklund/omarchy-pbjorklund/bin/suspend-desktop.sh ;;|' "$HOME/.local/share/omarchy/bin/omarchy-menu"
fi

# Fix omarchy-menu browser reference while we're at it
if [ -f "$HOME/.local/share/omarchy/bin/omarchy-menu" ]; then
    echo "Fixing omarchy-menu browser reference..."
    sed -i 's/setsid chromium --new-window --app=/setsid zen-browser --new-window --app=/' "$HOME/.local/share/omarchy/bin/omarchy-menu"
fi

# Remove chromium desktop entry if it exists
if [ -f "applications/chromium.desktop" ]; then
    echo "Removing chromium desktop entry..."
    rm applications/chromium.desktop
fi

# Apply wake source configuration now
echo "Applying wake source configuration..."

# Disable all USB device wake sources first
for device in /sys/bus/usb/devices/*/power/wakeup; do
    if [ -w "$device" ] || sudo test -w "$device"; then
        echo disabled | sudo tee "$device" >/dev/null 2>&1 || true
    fi
done

# Find and configure keyboard
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

if [ -n "$keyboard_device" ]; then
    # Enable keyboard wake source
    echo "Enabling keyboard wake source..."
    echo enabled | sudo tee "/sys/bus/usb/devices/$keyboard_device/power/wakeup" >/dev/null 2>&1 || true
    
    # Find and enable keyboard's USB controllers
    real_path=$(readlink -f "/sys/bus/usb/devices/$keyboard_device")
    pci_devices=$(echo "$real_path" | grep -o "0000:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]\.[0-9]" | sort -u)
    
    echo "Enabling ACPI wake devices for keyboard..."
    for pci_device in $pci_devices; do
        acpi_device=$(grep "$pci_device" /proc/acpi/wakeup 2>/dev/null | awk '{print $1}' || true)
        if [ -n "$acpi_device" ]; then
            echo "Found ACPI device: $acpi_device ($pci_device)"
            if grep -q "^$acpi_device.*disabled" /proc/acpi/wakeup 2>/dev/null; then
                echo "Enabling $acpi_device"
                echo "$acpi_device" | sudo tee /proc/acpi/wakeup >/dev/null
            fi
        fi
    done
    
    # Disable other USB controllers
    echo "Disabling other USB controllers..."
    all_usb_controllers=$(grep -E "^(XHC|XH)[0-9]+" /proc/acpi/wakeup | awk '{print $1}')
    for controller in $all_usb_controllers; do
        # Skip controllers needed for keyboard
        needed=false
        for pci_device in $pci_devices; do
            if grep -q "$controller.*$pci_device" /proc/acpi/wakeup 2>/dev/null; then
                needed=true
                break
            fi
        done
        if [ "$needed" = false ] && grep -q "^$controller.*enabled" /proc/acpi/wakeup 2>/dev/null; then
            echo "Disabling $controller"
            echo "$controller" | sudo tee /proc/acpi/wakeup >/dev/null
        fi
    done
    
    echo "Wake source setup complete!"
    echo "Keyboard device: $keyboard_device"
    echo "Keyboard wake status: $(cat "/sys/bus/usb/devices/$keyboard_device/power/wakeup" 2>/dev/null)"
else
    echo "Warning: No USB keyboard found!"
fi