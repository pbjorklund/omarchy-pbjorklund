#!/bin/bash

# Install Libation audiobook downloader
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_package "libation"