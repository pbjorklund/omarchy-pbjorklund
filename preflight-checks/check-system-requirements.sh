#!/bin/bash
set -e

# Validate system requirements
echo "Validating system requirements..."

command -v pacman &> /dev/null || show_error "Requires Arch Linux"
command -v yay &> /dev/null || show_error "yay not found (should be installed by omarchy)"

echo "✓ System validation complete"