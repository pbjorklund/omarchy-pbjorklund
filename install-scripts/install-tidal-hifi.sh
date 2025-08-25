#!/bin/bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_tidal_hifi() {
    install_package "tidal-hifi-bin"
}

install_tidal_hifi