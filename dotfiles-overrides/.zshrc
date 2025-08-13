plugins=(git)

export FORCE_COLOR=1  # Enable colored output for tools

# Essential Aliases
alias ll='ls -alF'             # Long listing with file types
alias la='ls -A'               # All files except . and ..
alias l='ls -CF'               # Compact listing with file types
alias grep='grep --color=auto' # Colorized grep output
alias ls='ls --color=auto'     # Colorized ls output

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
[[ -f ~/.zsh_aliases ]] && source ~/.zsh_aliases
[[ -f ~/.zsh_local ]] && source ~/.zsh_local

if [[ $(whoami) == "vscode" ]]; then
    export ZSH="$HOME/.oh-my-zsh"
    ZSH_THEME="devcontainers"
    source $ZSH/oh-my-zsh.sh
    plugins=(git)
    DISABLE_AUTO_UPDATE=true
    DISABLE_UPDATE_PROMPT=true
    export PATH=/home/vscode/.opencode/bin:$PATH
    export TERM=xterm-256color # Ensure terminal compatibility for non-vscode
    export COLORTERM=truecolor # Enable true color support
else
    # Editor Configuration
    export EDITOR=nvim # Use neovim as default editor

    # Created by `pipx` on 2025-06-16 12:33:17
    export PATH="$PATH:/home/pbjorklund/.local/bin"
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

    # opencode
    export PATH=/home/pbjorklund/.opencode/bin:$PATH
fi

# SSH wrapper to handle terminal compatibility
ssh() {
  # If current TERM is kitty-based, use xterm-256color for SSH
  if [[ "$TERM" == *"kitty"* ]]; then
    env TERM=xterm-256color command ssh "$@"
  else
    command ssh "$@"
  fi
}
