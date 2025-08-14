#!/bin/bash
set -e

# Run the wake source configuration
/home/pbjorklund/omarchy-pbjorklund/bin/setup-wake-sources.sh

# Suspend the system
systemctl suspend
