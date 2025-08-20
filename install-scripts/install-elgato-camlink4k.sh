#!/bin/bash

set -e
source "$(dirname "$(dirname "$0")")/utils.sh"

init_logging "install-elgato-camlink4k"

# Install V4L2 utilities for USB Video Class devices
if ! pacman -Q v4l-utils &> /dev/null; then
    show_action "Installing V4L2 utilities"
    log_command "sudo pacman -S --noconfirm v4l-utils" \
        "v4l-utils-install" \
        "V4L2 utilities installed" \
        "V4L2 utilities installation failed"
else
    show_success "V4L2 utilities already installed"
fi

# Install GStreamer plugins for video capture
if ! pacman -Q gst-plugins-good &> /dev/null; then
    show_action "Installing GStreamer good plugins"
    log_command "sudo pacman -S --noconfirm gst-plugins-good" \
        "gstreamer-good-install" \
        "GStreamer good plugins installed" \
        "GStreamer good plugins installation failed"
else
    show_success "GStreamer good plugins already installed"
fi

# Install GStreamer bad plugins (for additional video formats)
if ! pacman -Q gst-plugins-bad &> /dev/null; then
    show_action "Installing GStreamer bad plugins"
    log_command "sudo pacman -S --noconfirm gst-plugins-bad" \
        "gstreamer-bad-install" \
        "GStreamer bad plugins installed" \
        "GStreamer bad plugins installation failed"
else
    show_success "GStreamer bad plugins already installed"
fi

# Install OBS Studio for capture card usage
if ! pacman -Q obs-studio &> /dev/null; then
    show_action "Installing OBS Studio"
    log_command "sudo pacman -S --noconfirm obs-studio" \
        "obs-studio-install" \
        "OBS Studio installed" \
        "OBS Studio installation failed"
else
    show_success "OBS Studio already installed"
fi

# Add user to video group for device access
if ! groups "$USER" | grep -q video; then
    show_action "Adding user to video group"
    log_command "sudo usermod -a -G video $USER" \
        "video-group-add" \
        "User added to video group (reboot required)" \
        "Failed to add user to video group"
else
    show_success "User already in video group"
fi

show_success "Elgato CamLink 4K driver setup complete"
echo -e "${YELLOW}Note:${NC} CamLink 4K works as UVC device. If issues persist, try:"
echo "  - Check device with: lsusb"
echo "  - List video devices with: v4l2-ctl --list-devices"
echo "  - Test capture with: ffplay /dev/videoX"