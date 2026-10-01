# ==============================================================================
# .zshrc — Generic zsh configuration (macOS / Linux)
# Meant to work standalone on any machine (no dependencies on bootstrap/homelab)
# ==============================================================================

# ==============================================================================
# EXIT EARLY — Non-interactive shells
# ==============================================================================
[[ $- != *i* ]] && return

# ==============================================================================
# SHELL OPTIONS
# ==============================================================================
setopt APPEND_HISTORY         # Append to history, don't overwrite
setopt INC_APPEND_HISTORY     # Write to history immediately
setopt HIST_IGNORE_DUPS       # Ignore duplicate commands
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS     # Remove extra blanks from history
setopt AUTO_CD                # cd into directory by typing its name
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shells

# ==============================================================================
# HISTORY
# ==============================================================================
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=20000

# ==============================================================================
# COLORS — Prompt variables (zsh %{...%} wrappers)
# ==============================================================================
autoload -U colors && colors

export NC="%{$reset_color%}"
export RED="%{$fg[red]%}"
export GREEN="%{$fg[green]%}"
export YELLOW="%{$fg[yellow]%}"
export BLUE="%{$fg[blue]%}"
export PURPLE="%{$fg[magenta]%}"
export CYAN="%{$fg[cyan]%}"
export WHITE="%{$fg[white]%}"
export GRAY="%{$fg_bold[black]%}"

# ==============================================================================
# PROMPT — Generic, overridden in .zshrc_homelab
# ==============================================================================

# Short username: if it contains "stephane", display just "stephane"
if [[ "$USER" == *stephane* ]]; then
    _SHORT_USER="stephane"
else
    _SHORT_USER="$USER"
fi

# User color: red for root and admin accounts, cyan for centreon, green for regular
if [[ "$USER" == *adm* || "$USER" == "root" ]]; then
    _USER_COLOR="${RED}"
elif [[ "$USER" == centreon* ]]; then
    _USER_COLOR="${CYAN}"
else
    _USER_COLOR="${GREEN}"
fi

# Hostname in lowercase
_SHORT_HOST="${HOST:l}"

PROMPT="${CYAN}%*${NC} ${_USER_COLOR}${_SHORT_USER}${NC}@${BLUE}${_SHORT_HOST}${NC}:${CYAN}%~${NC} %# "

# ==============================================================================
# ENVIRONMENT
# ==============================================================================

# Locale — Force English messages in terminal
export LANG="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"

# Editor — fallback chain: vim.tiny → vim → vi
if (( $+commands[vim.tiny] )); then
    export EDITOR=vim.tiny
    export VISUAL=vim.tiny
elif (( $+commands[vim] )); then
    export EDITOR=vim
    export VISUAL=vim
else
    export EDITOR=vi
    export VISUAL=vi
fi

# Pager
export LESS='-R --quiet'

# ==============================================================================
# PATH
# ==============================================================================
[ -d "$HOME/bin" ] && path=("$HOME/bin" $path)
[ -d "$HOME/.local/bin" ] && path=("$HOME/.local/bin" $path)

# ==============================================================================
# ALIASES — Colorization
# ==============================================================================
# macOS uses BSD ls (no --color), GNU ls uses --color
if ls --color=auto / &>/dev/null; then
    alias ls='ls --color=auto'
else
    alias ls='ls -G'
fi
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# ==============================================================================
# ALIASES — Listing (ls, eza, lsd)
# ==============================================================================
alias la='ls -A'
alias ll='ls -alF'
alias ls-l='ls -l'

if (( $+commands[eza] )); then
    alias exa='eza -l --icons -a -H'
    alias e='eza -l --icons -a -H'
elif (( $+commands[exa] )); then
    alias exa='exa -l --icons -a -H'
    alias e='exa -l --icons -a -H'
else
    alias exa='ls -l'
    alias e='ls -l'
fi

if (( $+commands[lsd] )); then
    alias l='lsd -la'
else
    alias l='ls -CF'
fi

# ==============================================================================
# ALIASES — Navigation
# ==============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ==============================================================================
# COMPLETION
# ==============================================================================
autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive completion

# ==============================================================================
# KEY BINDINGS
# ==============================================================================
bindkey -e                          # Emacs key bindings (default macOS behavior)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ==============================================================================
# YADM AUTO-PULL — Sync dotfiles once per day (silent)
# ==============================================================================
if command -v yadm &>/dev/null; then
    mkdir -p "$HOME/.cache"
    _yadm_state="$HOME/.cache/.yadm_pull_last_run"
    _yadm_run=true
    if [[ -f "$_yadm_state" ]]; then
        _yadm_age=$(( $(date +%s) - $(stat -f %m "$_yadm_state" 2>/dev/null || echo 0) ))
        (( _yadm_age < 86400 )) && _yadm_run=false
    fi
    if [[ "$_yadm_run" == true ]]; then
        # Run in background with timeout to avoid blocking shell startup
        ( timeout 10 yadm pull --quiet 2>/dev/null && touch "$_yadm_state" ) &!
    fi
    unset _yadm_state _yadm_age _yadm_run
fi

# ==============================================================================
# EXTENSIONS — Machine-specific profiles
# ==============================================================================
[ -f ~/.zshrc_homelab ] && source ~/.zshrc_homelab

# export CUSTOMER=<client_name>  # Positionner cette variable sur les environnements clients

