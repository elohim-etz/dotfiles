# --- Environment setup ---
export ZSH_DISABLE_COMPFIX=true
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS='-R'
export TERM="xterm-256color"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# --- PATH setup ---
export PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH"

# --- History configuration ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY INC_APPEND_HISTORY
setopt HIST_REDUCE_BLANKS HIST_VERIFY EXTENDED_HISTORY
setopt HIST_IGNORE_SPACE

# --- Shell behavior ---
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt CORRECT
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt COMPLETE_IN_WORD

# --- Completion system ---
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"

# Enable case-insensitive completion
zstyle ':completion:*' matcher-list '' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-zA-Z}={A-Za-z}' \
  'r:|=* m:{a-zA-Z}={A-Za-z}'

# --- Starship prompt ---
eval "$(starship init zsh)"

# --- Zinit (plugin manager) ---
# Initialize Zinit
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
  mkdir -p $HOME/.local/share/zinit && \
  git clone https://github.com/zdharma-continuum/zinit.git $HOME/.local/share/zinit/zinit.git
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# --- Plugins ---
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light agkozak/zsh-z  # for directory jumping

# Optional: Lazy load commands
zinit ice wait lucid
zinit light junegunn/fzf-bin

# --- Aliases ---
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
alias g='git'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate'
alias update='sudo pacman -Syu --noconfirm'
alias yayu='yay -Syu --noconfirm'

# --- FZF integration ---
if command -v fzf >/dev/null 2>&1; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# --- Custom prompt symbols (Starship handles most of this) ---
# You can configure more in ~/.config/starship.toml

# --- Keybindings ---
bindkey -e  # Vim mode
bindkey '^R' history-incremental-search-backward
bindkey '^[[Z' reverse-menu-complete  # Shift+Tab to go back in completions

# --- Useful functions ---
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"   ;;
      *.tar.gz)    tar xzf "$1"   ;;
      *.bz2)       bunzip2 "$1"   ;;
      *.rar)       unrar x "$1"   ;;
      *.gz)        gunzip "$1"    ;;
      *.tar)       tar xf "$1"    ;;
      *.tbz2)      tar xjf "$1"   ;;
      *.tgz)       tar xzf "$1"   ;;
      *.zip)       unzip "$1"     ;;
      *.Z)         uncompress "$1";;
      *.7z)        7z x "$1"      ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# --- Fast startup fix ---
zinit cdreplay -q

export GPG_TTY=$(tty)
