#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Configure USB Audio for analog line out
# Fixes issue where PipeWire defaults to S/PDIF instead of analog speakers
#
# Problem: USB Audio interfaces often have multiple outputs (S/PDIF digital, 
# analog speakers, headphones). PipeWire may default to digital S/PDIF output
# instead of analog speakers where your physical speakers are connected.
#
# Solution: Explicitly set USB Audio analog speakers as the default sink

show_action "Configuring USB Audio for analog line out"

# Ensure PipeWire services are running
if ! systemctl --user is-active --quiet pipewire; then
    show_action "Starting PipeWire services"
    systemctl --user start pipewire pipewire-pulse wireplumber
    sleep 3
fi

# Quick check for USB audio device before waiting
if ! pactl list sinks short | grep -q "usb-Generic_USB_Audio"; then
    echo "No USB Audio device detected - audio will use system defaults"
    echo "This is normal if you don't have a USB audio interface"
    exit 0
fi
wait_for_usb_audio() {
    local timeout=15
    local count=0
    
    echo "Waiting for USB Audio device detection..."
    while [ $count -lt $timeout ]; do
        if pactl list sinks short | grep -q "usb-Generic_USB_Audio.*Speaker"; then
            echo "USB Audio speakers detected"
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    echo "USB Audio speakers not detected after ${timeout}s"
    echo "Available sinks:"
    pactl list sinks short || echo "No sinks available"
    return 1
}

# Set USB Audio analog speakers as default if available
if wait_for_usb_audio; then
    # Set analog speakers as default sink
    if pactl set-default-sink alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink; then
        show_success "Set USB Audio analog speakers as default output"
        
        # Verify the setting
        sleep 1
        if pactl info | grep -q "usb-Generic_USB_Audio.*Speaker"; then
            show_success "USB Audio configuration successful - analog speakers are now default"
        else
            echo "Warning: Default sink verification failed"
        fi
    else
        echo "Warning: Failed to set USB Audio speakers as default"
    fi
else
    echo "USB Audio device not found - audio will use system defaults"
    echo "This is normal if you don't have a USB audio interface"
fi