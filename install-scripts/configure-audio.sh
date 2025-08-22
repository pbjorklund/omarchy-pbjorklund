#!/bin/bash
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

# Configure Audio Output Preferences
# Handles both USB Audio and HDMI audio receiver setup
#
# USB Audio: 3.5mm jack → Technics amp → speakers (primary/default setup)
# HDMI Audio: Onkyo receiver for TV watching (secondary, manual switching)
#
# Priority: 1) USB Audio speakers (default), 2) Onkyo receiver (available for manual use), 3) system defaults

show_action "Configuring audio output preferences"

# Ensure PipeWire services are running
if ! systemctl --user is-active --quiet pipewire; then
    show_action "Starting PipeWire services"
    systemctl --user start pipewire pipewire-pulse wireplumber
    sleep 3
fi

# Function to configure Onkyo receiver if connected
configure_onkyo_receiver() {
    # Check if TX-SR444 receiver is connected via HDMI
    if cat /proc/asound/card*/eld#* 2>/dev/null | grep -q "TX-SR444"; then
        show_action "Onkyo TX-SR444 receiver detected, configuring..."
        
        # Set card profile to HDMI stereo (extra3 maps to the receiver)
        if pactl set-card-profile alsa_card.pci-0000_03_00.1 output:hdmi-stereo-extra3 2>/dev/null; then
            sleep 2  # Allow profile to activate
            
            # Set as default sink
            if pactl set-default-sink alsa_output.pci-0000_03_00.1.hdmi-stereo-extra3 2>/dev/null; then
                show_success "Onkyo receiver configured as default audio output"
                return 0
            fi
        fi
        echo "Warning: Failed to configure Onkyo receiver, falling back to other options"
    fi
    return 1
}
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

# Configure USB Audio as primary (Technics amp setup)
if pactl list sinks short | grep -q "usb-Generic_USB_Audio"; then
    if wait_for_usb_audio; then
        if pactl set-default-sink alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink; then
            show_success "Set USB Audio (Technics amp) as default output"
            
            # Verify the setting
            sleep 1
            if pactl info | grep -q "usb-Generic_USB_Audio.*Speaker"; then
                show_success "USB Audio configuration successful"
            else
                echo "Warning: Default sink verification failed"
            fi
        else
            echo "Warning: Failed to set USB Audio speakers as default"
        fi
    else
        echo "USB Audio device not found - using system defaults"
    fi
else
    echo "No USB Audio device detected - using system defaults"
fi

# Also configure Onkyo receiver profile (for manual TV switching)
if configure_onkyo_receiver; then
    # Reset back to USB Audio as default after configuring Onkyo
    if pactl list sinks short | grep -q "usb-Generic_USB_Audio"; then
        pactl set-default-sink alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink 2>/dev/null || true
    fi
    echo "✓ Onkyo receiver configured and available for manual switching"
else
    echo "Onkyo receiver not detected (normal if TV is off)"
fi