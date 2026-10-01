# ==============================================================================
# .bashrc — Generic bash configuration (Linux, all distributions)
# Meant to work standalone on any machine (no dependencies on bootstrap/homelab)
# ==============================================================================

# ==============================================================================
# EXIT EARLY — Non-interactive shells
# ==============================================================================
case $- in
    *i*) ;;
      *) return;;
esac

# ==============================================================================
# SHELL OPTIONS
# ==============================================================================
command -v shopt &>/dev/null && shopt -s histappend    # Append to history, don't overwrite
command -v shopt &>/dev/null && shopt -s checkwinsize  # Update LINES/COLUMNS after each command

# ==============================================================================
# HISTORY
# ==============================================================================
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=20000
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# ==============================================================================
# COLORS — PS1-compatible escape sequences
# ==============================================================================
export NC='\[\033[0m\]'
export RED='\[\033[0;31m\]'
export GREEN='\[\033[0;32m\]'
export ORANGE='\[\033[0;33m\]'
export YELLOW='\[\033[0;33m\]'
export BLUE='\[\033[0;34m\]'
export PURPLE='\[\033[0;35m\]'
export CYAN='\[\033[0;36m\]'
export WHITE='\[\033[0;37m\]'
export GRAY='\[\033[1;30m\]'

# ==============================================================================
# PROMPT — Generic, overridden in .bashrc_homelab
# ==============================================================================

# Short username: if it contains "stephane", display just "stephane"
if [[ "$USER" == *stephane* ]]; then
    _SHORT_USER="stephane"
else
    _SHORT_USER="$USER"
fi

# User color: red for root and admin accounts, green for regular
if [[ "$USER" == *adm* || "$USER" == "root" ]]; then
    _USER_COLOR="${RED}"
else
    _USER_COLOR="${GREEN}"
fi

# Hostname in lowercase
_SHORT_HOST="$(hostname | tr '[:upper:]' '[:lower:]')"

PS1="${debian_chroot:+($debian_chroot)}${CYAN}\t${NC} ${_USER_COLOR}${_SHORT_USER}${NC}@${BLUE}${_SHORT_HOST}${NC}:${CYAN}\w${NC} \$ "

# ==============================================================================
# ENVIRONMENT
# ==============================================================================

# Locale — Force English messages in terminal
export LANG="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"

# Editor — fallback chain: vim.tiny → vim → vi
if command -v vim.tiny &>/dev/null; then
    export EDITOR=vim.tiny
    export VISUAL=vim.tiny
elif command -v vim &>/dev/null; then
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
[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# ==============================================================================
# ALIASES — Colorization
# ==============================================================================
if command -v dircolors &>/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
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
alias l.='ls -d .* --color=auto'

if command -v eza &>/dev/null; then
    alias exa='eza -l --icons -a -H'
    alias e='eza -l --icons -a -H'
elif command -v exa &>/dev/null; then
    alias exa='exa -l --icons -a -H'
    alias e='exa -l --icons -a -H'
else
    alias exa='ls -l --color=auto'
    alias e='ls -l --color=auto'
fi

if command -v lsd &>/dev/null; then
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
# ALIASES — Notifications (desktop only)
# ==============================================================================
if command -v notify-send &>/dev/null; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# ==============================================================================
# BASH COMPLETION
# ==============================================================================
if command -v shopt &>/dev/null; then
    if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
    fi
fi

# ==============================================================================
# YADM AUTO-PULL — Sync dotfiles once per day (silent)
# ==============================================================================
if command -v yadm &>/dev/null; then
    mkdir -p "$HOME/.cache"
    _yadm_state="$HOME/.cache/.yadm_pull_last_run"
    _yadm_run=true
    if [[ -f "$_yadm_state" ]]; then
        _yadm_age=$(( $(date +%s) - $(stat -c %Y "$_yadm_state" 2>/dev/null || echo 0) ))
        (( _yadm_age < 86400 )) && _yadm_run=false
    fi
    if [[ "$_yadm_run" == true ]]; then
        # Run in background with timeout to avoid blocking shell startup
        ( timeout 10 yadm pull --quiet 2>/dev/null && touch "$_yadm_state" ) & disown
    fi
    unset _yadm_state _yadm_age _yadm_run
fi

# ==============================================================================
# TMUX / SCREEN WRAPPER - Guard against running upgrades outside detached session
# ==============================================================================
_check_mux_session() {
    # Skip check if already inside tmux or screen
    case "${TMUX}${STY}" in
        ?*) return 0 ;;
    esac

    # Prompt warning
    printf "\n\033[1;33m[WARNING]\033[0m You are not running inside a tmux/screen session!\n"
    read -r -p "Proceed anyway without a detached session? [y/N] " response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            printf "Aborted. Launch \`tmux\` or \`screen\` first.\n\n"
            return 1
            ;;
    esac
}

# APT wrapper
apt() {
    case "$1" in
        upgrade|dist-upgrade|full-upgrade)
            _check_mux_session || return 1
            ;;
    esac
    command apt "$@"
}

# NALA wrapper
nala() {
    case "$1" in
        upgrade)
            _check_mux_session || return 1
            ;;
    esac
    command nala "$@"
}

# DNF wrapper
dnf() {
    case "$1" in
        upgrade|update|system-upgrade)
            _check_mux_session || return 1
            ;;
    esac
    command dnf "$@"
}

# ==============================================================================
# EXTENSIONS — Machine-specific profiles
# ==============================================================================
[ -f ~/.bashrc_homelab ] && source ~/.bashrc_homelab


# export CUSTOMER=<client_name>  # Positionner cette variable sur les environnements clients
