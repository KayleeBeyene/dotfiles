# ============================================================================
# Zinit Plugin Manager Setup
# ============================================================================

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Load a few important annexes, without Turbo
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ============================================================================
# Plugins
# ============================================================================

# Starship prompt
zinit light starship/starship

# Zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# ============================================================================
# Completion System
# ============================================================================

# Load completions (moved after plugins for better performance)
autoload -U compinit && compinit

zinit cdreplay -q

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# ============================================================================
# Key Bindings
# ============================================================================

bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^f' autosuggest-accept

# ============================================================================
# History Configuration
# ============================================================================

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase

# History options
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks

# ============================================================================
# Shell Options
# ============================================================================

setopt auto_cd              # cd by typing directory name if it's not a command
setopt correct              # auto correct mistakes
setopt glob_dots            # include hidden files in globbing

# ============================================================================
# Environment Variables
# ============================================================================

export EDITOR="nvim"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export LEDGER_FILE=~/finance/2025.journal

# Source API keys from separate file (create ~/.config/api-keys with your keys)
# Example content: export OPEN_WEATHER_API_KEY="your_key_here"
if [ -f "$HOME/.config/api-keys" ]; then
    source "$HOME/.config/api-keys"
fi

# ============================================================================
# FZF Configuration
# ============================================================================

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# FZF options with bat and eza previews
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Use fd instead of find
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Advanced customization of fzf options via _fzf_comprun function
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# Use fd for listing path candidates
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Source fzf-git.sh if it exists
if [ -f "$HOME/fzf-git.sh/fzf-git.sh" ]; then
    source "$HOME/fzf-git.sh/fzf-git.sh"
fi

# ============================================================================
# Aliases
# ============================================================================

alias ls="eza --color=always --long --git --icons=always"
alias ll="eza -la --color=always --git --icons=always"
alias cat="bat"
alias vim="nvim"
alias cd="z"

# ============================================================================
# Tool Integrations
# ============================================================================

# Starship prompt
eval "$(starship init zsh)"

# thefuck - command correction
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# Zoxide - better cd
eval "$(zoxide init zsh)"

# Yazi file manager integration
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

