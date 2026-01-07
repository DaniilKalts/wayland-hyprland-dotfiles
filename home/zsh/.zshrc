#  ╔═╗╔═╗╦ ╦╦═╗╔═╗  ╔═╗╔═╗╔╗╔╔═╗╦╔═╗
#  ╔═╝╚═╗╠═╣╠╦╝║    ║  ║ ║║║║╠╣ ║║ ╦
#  ╚═╝╚═╝╩ ╩╩╚═╚═╝  ╚═╝╚═╝╝╚╝╚  ╩╚═╝

# ------------------------------------------------------------------------------
# ⚡ PERFORMANCE: POWERLEVEL10K INSTANT PROMPT
#
# This must be at the top of ~/.zshrc to enable instant prompt.
# ------------------------------------------------------------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ------------------------------------------------------------------------------
# 🔧 ENVIRONMENT & PATHS
#
# Define environment variables, paths to binaries, and essential settings.
# ------------------------------------------------------------------------------

# --> Core Paths
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'
export HIST_STAMPS="%F %T" # Record timestamps for history

# --> Executable Path Configuration
# Paths are prepended to take precedence over system defaults.
export PATH="$HOME/.local/bin:$HOME/go/bin:/snap/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# --> pnpm Configuration
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;; # pnpm already in PATH
  *) export PATH="$PNPM_HOME:$PATH" ;; # Add pnpm to PATH
esac
# pnpm end

# ------------------------------------------------------------------------------
# 🎨 THEME & APPEARANCE
#
# Configure themes for shell, tools, and syntax highlighting.
# ------------------------------------------------------------------------------

# --> Dracula Theme for zsh-syntax-highlighting
# Must be set BEFORE sourcing the plugin.
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272A4'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[function]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[command]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#50FA7B,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#FFB86C,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFB86C'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFB86C'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#BD93F9'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF5555'
ZSH_HIGHLIGHT_STYLES[path]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#BD93F9'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[default]='fg=#F8F8F2'

# --> Dracula Theme for fzf
export FZF_DEFAULT_OPTS='--ansi --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# --> eza (ls replacement) Color Scheme
export EZA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:"

# --> Dracula TTY Colors (for Linux console)
if [ "$TERM" = "linux" ]; then
    printf %b '\e[40m\e[8]\e[37m\e[8]'
    printf %b '\e]P0282a36\e]P86272a4' # Black
    printf %b '\e]P1ff5555\e]P9ff7777' # Red
    printf %b '\e]P250fa7b\e]PA70fa9b' # Green
    printf %b '\e]P3f1fa8c\e]PBffb86c' # Yellow
    printf %b '\e]P4bd93f9\e]PCcfa9ff' # Blue
    printf %b '\e]P5ff79c6\e]PDff88e8' # Magenta
    printf %b '\e]P68be9fd\e]PE97e2ff' # Cyan
    printf %b '\e]P7f8f8f2\e]PFffffff' # White
    clear
fi

# ------------------------------------------------------------------------------
# 📦 OH MY ZSH CONFIGURATION
#
# Theme and plugins for Oh My Zsh. This must be set before sourcing oh-my-zsh.sh.
# ------------------------------------------------------------------------------

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  you-should-use
  zsh-history-substring-search
)

# ------------------------------------------------------------------------------
# 🚀 FRAMEWORK & CONFIG SOURCING
#
# Load Oh My Zsh, Powerlevel10k, and other external configurations.
# ------------------------------------------------------------------------------

source "$ZSH/oh-my-zsh.sh"

# --> Source Powerlevel10k configuration
# To customize, run `p10k configure` or edit `~/.p10k.zsh`.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# --> Source Cargo (Rust) environment if it exists
source "$HOME/.cargo/env" 2>/dev/null || true

# ------------------------------------------------------------------------------
# ⚙️ SHELL BEHAVIOR & OPTIONS
#
# Configure Zsh's built-in behavior with `setopt`.
# ------------------------------------------------------------------------------

setopt EXTENDED_HISTORY # Record timestamps and duration in history

# ------------------------------------------------------------------------------
# ⌨️ KEYBINDINGS & VI MODE
#
# Custom key mappings and shell editor settings.
# ------------------------------------------------------------------------------

# --> Enable Vi mode
bindkey -v

# --> Use 'jk' to quickly exit insert mode
function enter-vi-normal-mode { zle vi-cmd-mode }
zle -N enter-vi-normal-mode
bindkey -M viins 'jk' enter-vi-normal-mode

# --> Custom Keybindings (Insert & Command Mode)
bindkey -M viins '^[a' autosuggest-accept
bindkey -M vicmd '^[a' autosuggest-accept
bindkey -M viins '^F' fzf-file-widget
bindkey -M vicmd '^F' fzf-file-widget
bindkey -M viins '^P' fzf_preview
bindkey -M vicmd '^P' fzf_preview
bindkey -M viins '^G' rg_fzf_preview
bindkey -M vicmd '^G' rg_fzf_preview
# bindkey -M viins '^X' clear-screen-function # Placeholder for Ctrl+X

# --> Edit current command line in $EDITOR (Ctrl+X Ctrl+E)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M viins '^E' edit-command-line
bindkey -M vicmd '^E' edit-command-line

# ------------------------------------------------------------------------------
# 🏷️ ALIASES
#
# Shortcuts for frequently used commands.
# ------------------------------------------------------------------------------

# --> General & System
alias cls='clear'
alias rm='trash' # Safer 'rm'
alias copy='wl-copy <' # Wayland copy
alias shutdown='~/.local/bin/update-and-shutdown.sh'
alias restart='~/.local/bin/update-and-restart.sh'
alias neofetch='fastfetch'
alias pfetch='neofetch --config ~/.local/bin/fetches/penguinfetch.conf'

# --> Git Aliases (requires 'git' plugin for 'g')
alias glg="g log --graph --decorate --all --abbrev-commit --date=relative --color --pretty=format:'%C(bold yellow)%h%C(reset) %C(green)%ar%C(reset) %C(bold blue)%d%C(reset)%n  %s %C(dim white)– %an%C(reset)'"
alias glom="g log --format=%s"

# --> Tool Aliases
alias bcat='bat'
alias ls='eza --color=auto --group-directories-first'
alias ll='eza -l --color=auto --group-directories-first'
alias la='eza -a --color=auto --group-directories-first'
alias lia='eza -la --icons --color=always'
alias tree='eza --tree'
alias tree1='eza --tree --level=1'
alias tree2='eza --tree --level=2'
alias tree3='eza --tree --level=3'
alias tree4='eza --tree --level=4'
alias treea='eza --tree -a'
alias treea1='eza --tree -a --level=1'
alias treea2='eza --tree -a --level=2'
alias treea3='eza --tree -a --level=3'
alias treea4='eza --tree -a --level=4'
alias liatree='eza -la --icons --color=always --tree'
alias liatree1='eza -la --icons --color=always --tree --level=1'
alias liatree2='eza -la --icons --color=always --tree --level=2'
alias liatree3='eza -la --icons --color=always --tree --level=3'
alias liatree4='eza -la --icons --color=always --tree --level=4'

# --> Calendar Utilities
alias weekday='~/.local/bin/calendar/calendar_utils.sh get_day_of_week'
alias daydates='~/.local/bin/calendar/calendar_utils.sh get_dates_for_days_of_week'
alias daysbetween='~/.local/bin/calendar/calendar_utils.sh days_between_dates'

# ------------------------------------------------------------------------------
# 🛠️ CUSTOM FUNCTIONS
#
# Advanced shell functions for enhanced functionality.
# ------------------------------------------------------------------------------

# --> `bat` Wrappers
function bless() { bat --paging=always "$@"; }
function bhead() { bat --paging=never --line-range ":${2:-10}" "$@"; }
function btail() { tail -f "$1" | bat --paging=never -l "${2:-sh}"; }

# --> `yazi` File Manager Integration (cd on quit)
function yy() {
  local tmp
  tmp="$(mktemp -t \"yazi-cwd.XXXXXX\")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd" || return
  fi
  rm -f -- "$tmp"
  zle reset-prompt
}

# --> fzf: History Search
fzf-history-widget() {
  local selected_command
  selected_command=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | fzf +s --tac) && LBUFFER=$selected_command
  zle redisplay
}
zle -N fzf-history-widget

# --> fzf: File/Directory Search with `eza` preview
fzf-file-widget() {
  local selected_file
  selected_file=$(find . \( -type d -o -type f \) -print 2> /dev/null | fzf --height 60% --reverse --preview 'eza -l --color=always --icons {}')
  if [ -n "$selected_file" ]; then
    LBUFFER="${LBUFFER}${selected_file}"
  fi
  zle reset-prompt
}
zle -N fzf-file-widget

# --> fzf: File Content Preview with `bat`
fzf_preview() {
  local selected_file
  selected_file=$(find . -type f \( ! -name "*.png" ! -name "*.webp" ! -name "*.svg" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.gif" ! -name "*.bmp" ! -name "*.mp3" ! -name "*.wav" ! -name "*.flac" ! -name "*.ogg" ! -name "*.m4a" ! -name "*.aac" ! -name "*.wma" \) -print 2> /dev/null | fzf --height 60% --reverse --preview 'bat --style=numbers --color=always --line-range=:500 {}' --preview-window=right:60%)
  if [ -n "$selected_file" ]; then
    LBUFFER="${LBUFFER}${selected_file}"
  fi
  zle reset-prompt
}
zle -N fzf_preview

# --> fzf: Ripgrep Content Search
# Searches for the string in the command buffer ($LBUFFER) when you press Ctrl+G.
rg_fzf_preview() {
  # If the buffer is empty, show a message and do nothing.
  if [[ -z "$LBUFFER" ]]; then
    # zle -M displays a message at the bottom of the screen.
    zle -M "Ripgrep search: Type a query before pressing Ctrl+G"
    return 1
  fi

  # First, run rg and see if there are any matches.
  local rg_output
  rg_output=$(rg --column --line-number --no-heading --color=always -F "$LBUFFER" 2>/dev/null)

  # If rg produces no output, show a message and stop.
  # This prevents fzf from opening and immediately closing.
  if [[ -z "$rg_output" ]]; then
    zle -M "No matches found for: '$LBUFFER'"
    return 1
  fi

  local selected_line
  # Pipe the results from rg into fzf for interactive selection.
  selected_line=$(echo "$rg_output" \
    | fzf --ansi --exact --no-sort --preview 'bat --style=numbers --color=always --line-range=$(awk -F: "{if ($2 > 10) {print $2-10":"$2+10} else {print \"1:\"$2+10}}" <<< {}) --highlight-line=$(awk -F: "{print $2}" <<< {}) $(awk -F: "{print $1}" <<< {})'
    --preview-window=right:60%:wrap --height=60% --border)

  if [ -n "$selected_line" ]; then
    local file=$(echo "$selected_line" | cut -d: -f1)
    local line=$(echo "$selected_line" | cut -d: -f2)
    # Replace the search query with the result for easy opening.
    LBUFFER="+$line $file"
    RBUFFER=""
    zle redisplay
  fi
}
zle -N rg_fzf_preview

# ==============================================================================
#                             ✨ End of Configuration ✨
# ==============================================================================

# ============================================================================
# Dracula Theme Configuration
# ============================================================================

# Dracula theme for fzf
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Dracula TTY colors (for Linux console)
if [ "$TERM" = "linux" ]; then
    printf %b '\e[40m' '\e[8]'
    printf %b '\e[37m' '\e[8]'
    printf %b '\e]P0282a36'
    printf %b '\e]P86272a4'
    printf %b '\e]P1ff5555'
    printf %b '\e]P9ff7777'
    printf %b '\e]P250fa7b'
    printf %b '\e]PA70fa9b'
    printf %b '\e]P3f1fa8c'
    printf %b '\e]PBffb86c'
    printf %b '\e]P4bd93f9'
    printf %b '\e]PCcfa9ff'
    printf %b '\e]P5ff79c6'
    printf %b '\e]PDff88e8'
    printf %b '\e]P68be9fd'
    printf %b '\e]PE97e2ff'
    printf %b '\e]P7f8f8f2'
    printf %b '\e]PFffffff'
    clear
fi

# Dracula zsh-syntax-highlighting colors
# Must be set BEFORE sourcing zsh-syntax-highlighting
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272A4'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[function]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[command]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#50FA7B,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#FFB86C,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFB86C'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFB86C'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#BD93F9'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF5555'
ZSH_HIGHLIGHT_STYLES[path]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#BD93F9'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[default]='fg=#F8F8F2'
