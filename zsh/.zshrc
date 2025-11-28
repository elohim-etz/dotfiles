# ======================================================================
#   Environment Setup
# ======================================================================

export ZSH_DISABLE_COMPFIX=true
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS='-R'
export TERM="xterm-256color"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# PATH
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE


# ======================================================================
#   Shell Behavior
# ======================================================================

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt CORRECT
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt COMPLETE_IN_WORD


# ======================================================================
#   Completion
# ======================================================================

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

# Case-insensitive smart matching
zstyle ':completion:*' matcher-list '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-zA-Z}={A-Za-z}' \
  'r:|=* m:{a-zA-Z}={A-Za-z}'


# ======================================================================
#   Prompt
# ======================================================================

eval "$(starship init zsh)"


# ======================================================================
#   Zinit
# ======================================================================

# Setup & load Zinit
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  mkdir -p $HOME/.local/share/zinit && \
  git clone https://github.com/zdharma-continuum/zinit.git \
    $HOME/.local/share/zinit/zinit.git
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Replay compdump BEFORE any plugin loads (fixes first-line issues)
zinit cdreplay -q


# ======================================================================
#   Plugins
# ======================================================================

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light agkozak/zsh-z

# Safe to lazy-load this one
zinit ice wait lucid
zinit light junegunn/fzf-bin


# ======================================================================
#   Aliases
# ======================================================================

alias ls='ls --color=auto --group-directories-first'
alias la='ls -A'
alias ll='ls -lh'
alias lla='ls -lAh'

alias ..='cd ..'
alias ...='cd ../..'

alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias clr='clear'
alias svim='sudo nvim'

alias cat='bat --style=plain --paging=never 2>/dev/null || cat'

# Package managers
alias update='sudo pacman -Syu --noconfirm'
alias yayu='yay -Syu --noconfirm'


# ======================================================================
#   FZF Integration
# ======================================================================

if command -v fzf >/dev/null 2>&1; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi


# ======================================================================
#   Keybindings
# ======================================================================

bindkey -e
bindkey '^R' history-incremental-search-backward
bindkey '^[[Z' reverse-menu-complete


# ======================================================================
#   Functions
# ======================================================================

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1" ;;
      *.tar.gz)    tar xzf "$1" ;;
      *.bz2)       bunzip2 "$1" ;;
      *.rar)       unrar x "$1" ;;
      *.gz)        gunzip "$1" ;;
      *.tar)       tar xf "$1" ;;
      *.tbz2)      tar xjf "$1" ;;
      *.tgz)       tar xzf "$1" ;;
      *.zip)       unzip "$1" ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1" ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


# ======================================================================
#   GPG
# ======================================================================

export GPG_TTY=$(tty)
