# ---------------------------------------------------------------------------
# EXIT CONDITIONS
# ---------------------------------------------------------------------------
# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ---------------------------------------------------------------------------
# HISTORY CONTROL
# ---------------------------------------------------------------------------
export HISTCONTROL=ignoreboth
export HISTSIZE=10000
export HISTFILESIZE=20000
command -v shopt &>/dev/null && shopt -s histappend
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# ---------------------------------------------------------------------------
# ALIASES
# ---------------------------------------------------------------------------
# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
fi
# General aliases
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
# Confirmation aliases (prevents accidental deletion/overwriting)
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
# 'ls' aliases
alias la='ls -A'
alias ll='ls -alF'
alias ls-l='ls -l'
alias l.='ls -d .* --color=auto'
# Set aliases for eza only if it's installed
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
# Set alias for lsd only if it's installed
if command -v lsd &>/dev/null; then
  alias l='lsd -la'
else
  alias l='ls -CF'
fi
# cd aliases
alias ..='cd ..'


# Human-readable output
alias df='df -h' # disk free
alias du='du -h' # disk usage

# Quick navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Define colors
if [ -f ~/.colors ]; then
  echo "🔄 Loading colors"
  source ~/.colors
fi

# Set the prompt string (PS1)
# Format: 🕒 HH:MM:SS user@hostname:~/current/path (git_branch) $
# PS1="${debian_chroot:+($debian_chroot)}🕒 ${COLOR_CYAN}\t${COLOR_RESET} ${COLOR_GREEN}\u@\h${COLOR_RESET}:${COLOR_BLUE}\w${COLOR_RESET} \$ " # Time, User, Host, and Directory
PS1="${debian_chroot:+($debian_chroot)}🕒 \[${COLOR_CYAN}\]\t\[${COLOR_RESET}\] \[${COLOR_GREEN}\]\u@\h\[${COLOR_RESET}\]:\[${COLOR_BLUE}\]\w\[${COLOR_RESET}\] \$ "

# ---------------------------------------------------------------------------
# ENVIRONMENT & PATH
# ---------------------------------------------------------------------------
# Set your preferred editor
export EDITOR=vim.tiny
export VISUAL=vim.tiny

# Add a user's local bin directory to the PATH, if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Add a user's local scripts directory to the PATH, if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# ---------------------------------------------------------------------------
# BASH COMPLETION & COLORIZATION
# ---------------------------------------------------------------------------
if command -v shopt &>/dev/null; then
  if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
      . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi
  fi
fi

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ----- END OF .bashrc -----

