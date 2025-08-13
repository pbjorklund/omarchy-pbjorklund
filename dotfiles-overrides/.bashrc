#!/bin/bash

# Bash configuration for development workstation
# Features: extended history, useful aliases, modern editor integration

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# History Configuration
shopt -s histappend   # Append to history file, don't overwrite
HISTSIZE=10000        # Commands in memory
HISTFILESIZE=20000    # Commands in history file
shopt -s checkwinsize # Update window size after each command

# Git branch detection function for prompt
git_branch() {
    local branch
    if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
        if [[ $branch == "HEAD" ]]; then
            branch=$(git rev-parse --short HEAD 2>/dev/null)
        fi
        echo " ($branch)"
    fi
}

# Prompt Configuration - colorized with git integration
# Colors: cyan user@host, blue path, green git branch, white prompt
PS1='\[\e[0;36m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;32m\]$(git_branch)\[\e[0m\]\$ '

# Essential Aliases
alias ll='ls -alF'             # Long listing with file types
alias la='ls -A'               # All files except . and ..
alias l='ls -CF'               # Compact listing with file types
alias grep='grep --color=auto' # Colorized grep output
alias ls='ls --color=auto'     # Colorized ls output
alias c='claude --dangerously-skip-permissions'     # Yolo Claude, skip permissions

# Disable pagers for better agent interaction
export SYSTEMD_PAGER=''                  # Disable pager for systemctl
export PAGER='cat'                       # Use cat instead of less/more
export MANPAGER='cat'                    # Use cat for manual pages
alias systemctl='systemctl --no-pager'   # Force systemctl to not use pager
alias journalctl='journalctl --no-pager' # Force journalctl to not use pager

# 1Password integration - only for non-vscode users
export SSH_AUTH_SOCK=~/.1password/agent.sock
export OP_BIOMETRIC_UNLOCK_ENABLED=true

# Conditional Loading
# Load additional configurations if they exist
[[ -f ~/.bash_aliases ]] && source ~/.bash_aliases
[[ -f ~/.bash_local ]] && source ~/.bash_local

if [[ $(whoami) != "vscode" ]]; then
    # Editor Configuration
    export EDITOR=nvim # Use neovim as default editor

    # Created by `pipx` on 2025-06-16 12:33:17
    export PATH="$PATH:$HOME/.local/bin"
    . "$HOME/.cargo/env"
    export PATH="$HOME/.cargo/bin:$PATH"

    # Disable crash reporting
    export GNOME_DISABLE_CRASH_DIALOG=1

    # Reduce information leakage
    umask 077 # Restrictive file permissions by default

    # Secure temporary files
    export TMPDIR="/tmp/$(whoami)"
    mkdir -p "$TMPDIR"
    chmod 700 "$TMPDIR"

    # npm configuration - use home directory for global packages to avoid permissions issues
    export NPM_CONFIG_PREFIX=~/.npm-global
    export PATH=~/.npm-global/bin:$PATH

    # GitHub token function - only loads when needed
    gh_token() {
        if [ -z "$GH_TOKEN" ]; then
            export GH_TOKEN=$(op item get "GitHub Personal Access Token" --fields credential --reveal 2>/dev/null)
        fi
        echo "$GH_TOKEN"
    }

    # SSH wrapper to handle terminal compatibility
    ssh() {
        # If current TERM is kitty-based, use xterm-256color for SSH
        if [[ "$TERM" == *"kitty"* ]]; then
            env TERM=xterm-256color command ssh "$@"
        else
            command ssh "$@"
        fi
    }

    # opencode
    export PATH=$HOME/.opencode/bin:$PATH

fi
export PATH="$HOME/.cargo/bin:$PATH"

# Only set TERM if not in tmux (let tmux handle it)
[[ -z "$TMUX" ]] && export TERM=xterm-256color
export COLORTERM=truecolor # Enable true color support

# Show system info and color test on new interactive shells (only if interactive)
if [[ $- == *i* ]] >/dev/null 2>&1; then
    fastfetch -c paleofetch
fi
