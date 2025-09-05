# -*- mode: sh; sh-indentation: 2; -*-
# ███████╗███████╗██╗  ██╗
# ╚══███╔╝██╔════╝██║  ██║
#   ███╔╝ ███████╗███████║
#  ███╔╝  ╚════██║██╔══██║
# ███████╗███████║██║  ██║
# ╚══════╝╚══════╝╚═╝  ╚═╝

# ==============================================================================
# Zinit Plugin Manager
# ==============================================================================
if [[ ! -f "$HOME/.local/share/zinit/zinit.git/zinit.zsh" ]]; then
    command mkdir -p "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git"
fi
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# ==============================================================================
# Performance Core
# ==============================================================================
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit -i -C
else
  compinit -i
fi

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=500000
setopt INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# ==============================================================================
# Plugin Configuration
# ==============================================================================
# Core UX plugins (loaded immediately)
zinit light-mode for \
  atinit"zicompinit; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions

# OMZ functionality replacements
zinit snippet OMZP::sudo
zinit snippet OMZP::copyfile

# Special case plugins
zinit light Aloxaf/fzf-tab     # Better tab completion

# ==============================================================================
# Command Not Found (Arch Native Implementation)
# ==============================================================================
command_not_found_handler() {
  local command="$1"
  local packages=($(pkgfile -b -- "$command" 2>/dev/null | sort -u))

  if (( ${#packages[@]} > 0 )); then
    echo "🔍 Command '$command' is provided by:"
    print -l -- "${packages[@]}"
    echo "Install with: sudo pacman -S <package>"
  else
    echo "🤷 Command '$command' not found in any package."
  fi

  return 127
}

# ==============================================================================
# Modern Shell Tools
# ==============================================================================
alias ls='lsd --group-dirs first --color always'
alias ll='ls -l'
alias la='ls -A'
alias lt='ls --tree'
alias cat='bat --paging=never'

# ==============================================================================
# Final Optimizations
# ==============================================================================
eval "$(starship init zsh)"

path=(
  $HOME/.local/bin
  /usr/local/bin
  /usr/bin
  /bin
  ${(@)path:#*Microsoft*}
)
typeset -U path

# ==============================================================================
# Interactive Session Only
# ==============================================================================
if [[ -o interactive ]]; then
  fastfetch
fi
