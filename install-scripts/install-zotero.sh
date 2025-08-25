#!/bin/bash

# Install Zotero reference management application
set -e

source "$(dirname "${BASH_SOURCE[0]}")/../utils.sh"

install_package "zotero"