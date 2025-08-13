#!/bin/bash

# Get the current keyboard layout more efficiently
# Uses hyprctl activeworkspace which is much faster than devices

# Get the active keyboard layout using the faster activeworkspace command
# This is much more efficient than parsing the entire devices output
layout=$(hyprctl getoption input:kb_layout | grep -o 'str: "[^"]*"' | sed 's/str: "\([^"]*\)"/\1/')

# Convert to short format based on the layout string
case "$layout" in
    "us") echo "EN" ;;
    "se") echo "SE" ;;
    "us,se") echo "EN" ;;  # Default to first layout
    *) echo "${layout:0:2}" | tr '[:lower:]' '[:upper:]' ;;
esac
