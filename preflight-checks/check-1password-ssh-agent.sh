#!/bin/bash
set -e

# Validate 1Password SSH agent
echo "Validating 1Password SSH agent..."

if [[ "$SSH_AUTH_SOCK" == *"1password"* ]] || [ -S "$HOME/.1password/agent.sock" ]; then
    echo "✓ 1Password SSH agent already configured"
else
    show_error "1Password SSH agent not configured - enable in 1Password Settings → Developer → SSH Agent"
fi