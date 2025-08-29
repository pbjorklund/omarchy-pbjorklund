#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_youtube_music() {
    # YouTube Music is deployed as a webapp via desktop files
    # No package installation needed - uses omarchy-launch-webapp
    echo "✓ YouTube Music webapp configured (desktop file deployment)"
}

install_youtube_music