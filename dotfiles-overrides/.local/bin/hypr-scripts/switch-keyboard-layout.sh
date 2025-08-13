#!/bin/bash

# Switch keyboard layout for all relevant keyboards
# This ensures both laptop and USB keyboards stay in sync

# Get list of all keyboard devices that have layouts configured
keyboards=$(/usr/bin/hyprctl devices | /usr/bin/grep -B 1 'us,se' | /usr/bin/grep -E 'at-translated-set-2-keyboard|usb-keyboard' | /usr/bin/grep -E '^\s+[a-z]' | /usr/bin/sed 's/^\s*//' | /usr/bin/sed 's/:$//')

# Switch layout for each keyboard
for keyboard in $keyboards; do
    /usr/bin/hyprctl switchxkblayout "$keyboard" next
done
