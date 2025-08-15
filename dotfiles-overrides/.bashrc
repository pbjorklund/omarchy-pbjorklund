#!/bin/bash

# Exit if shell is not interactive (prevents issues in scripts/non-interactive contexts)
case $- in
  *i*) ;;
  *) return ;;
esac

# =============================================================================
# SHELL CONFIGURATION
# =============================================================================

shopt -s histappend checkwinsize
HISTSIZE=10000
HISTFILESIZE=20000

git_branch() {
  local branch
  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    if [[ $branch == "HEAD" ]]; then
      branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi
    echo " ($branch)"
  fi
}

PS1='\[\e[0;36m\]\u@\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;32m\]$(git_branch)\[\e[0m\]\$ '

# =============================================================================
# ENVIRONMENT VARIABLES
# =============================================================================

export EDITOR=nvim
export SUDO_EDITOR="$EDITOR"
export BAT_THEME=ansi
export COLORTERM=truecolor

# Agent integration
export SYSTEMD_PAGER=''
export PAGER='cat'
export MANPAGER='cat'

# Security
umask 077
export TMPDIR="/tmp/$(whoami)"
mkdir -p "$TMPDIR"
chmod 700 "$TMPDIR"

# 1Password integration
export SSH_AUTH_SOCK=~/.1password/agent.sock
export OP_BIOMETRIC_UNLOCK_ENABLED=false

# =============================================================================
# PATH CONFIGURATION
# =============================================================================

export NPM_CONFIG_PREFIX=~/.npm-global
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$HOME/.opencode/bin:$PATH"

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# =============================================================================
# ALIASES
# =============================================================================

# Core utilities
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias systemctl='systemctl --no-pager'
alias journalctl='journalctl --no-pager'

# Non-VSCode only aliases and functions
if [[ $(whoami) != "vscode" ]]; then
  # File system
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
  alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
  alias cd="zd"

  # Application shortcuts
  alias c='claude --dangerously-skip-permissions'
  alias zel='zellij a -c'
fi

# =============================================================================
# FUNCTIONS
# =============================================================================

if [[ $(whoami) != "vscode" ]]; then
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf " \U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }

  open() {
    xdg-open "$@" >/dev/null 2>&1 &
  }

  n() {
    if [ "$#" -eq 0 ]; then
      nvim .
    else
      nvim "$@"
    fi
  }

  ssh() {
    if [[ "$TERM" == *"kitty"* ]]; then
      env TERM=xterm-256color command ssh "$@"
    else
      command ssh "$@"
    fi
  }
fi

# =============================================================================
# TOOL INTEGRATION
# =============================================================================

if [[ $(whoami) != "vscode" ]]; then
  command -v mise &>/dev/null && eval "$(mise activate bash)"
  command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

  if command -v fzf &>/dev/null; then
    [[ -f /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash
    [[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
  fi

  if [[ ! -v BASH_COMPLETION_VERSINFO && -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  fi
fi

if [[ "$OPENCODE" == "1" ]]; then
    export PAGER=cat
    export MANPAGER=cat
    export SYSTEMD_PAGER=
    # Disable git pager
    export GIT_PAGER=cat
    # Disable other common pagers
    alias less=cat
    alias more=cat
fi

# =============================================================================
# STARTUP
# =============================================================================

if [[ $- == *i* ]] >/dev/null 2>&1; then
  fastfetch
fi
