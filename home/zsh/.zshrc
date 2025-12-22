#  ╔═╗╔═╗╦ ╦╦═╗╔═╗  ╔═╗╔═╗╔╗╔╔═╗╦╔═╗
#  ╔═╝╚═╗╠═╣╠╦╝║    ║  ║ ║║║║╠╣ ║║ ╦
#  ╚═╝╚═╝╩ ╩╩╚═╚═╝  ╚═╝╚═╝╝╚╝╚  ╩╚═╝

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Enable plugins
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  you-should-use
  zsh-history-substring-search
)

# To record timestamps (epoch + duration) in a history file
setopt EXTENDED_HISTORY
export HIST_STAMPS="%F %T"

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Enable Vi mode
bindkey -v

# Custom keybinding: j followed by k to switch to normal mode in vi insert mode
function enter-vi-normal-mode {
  zle vi-cmd-mode
}
zle -N enter-vi-normal-mode
bindkey -M viins 'jk' enter-vi-normal-mode

# Custom Keybindings

## Bind Alt+a to accept autosuggestions in vi insert and command modes
bindkey -M viins '^[a' autosuggest-accept
bindkey -M vicmd '^[a' autosuggest-accept

## Bind Ctrl+F to fzf file/directory search in vi insert and command modes
bindkey -M viins '^F' fzf-file-widget
bindkey -M vicmd '^F' fzf-file-widget

## Bind Ctrl+P to fzf preview in vi insert and command modes
bindkey -M viins '^P' fzf_preview
bindkey -M vicmd '^P' fzf_preview

## Bind Ctrl+G to ripgrep fzf preview in vi insert and command modes
bindkey -M viins '^G' rg_fzf_preview
bindkey -M vicmd '^G' rg_fzf_preview

## Bind Ctrl+X to clean the terminal (function should be defined)

# fzf-related Functions

## fzf history search function
fzf-history-widget() {
  local selected_command
  selected_command=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | fzf +s --tac) && LBUFFER=$selected_command
  zle redisplay
}
zle -N fzf-history-widget

## fzf file/directory search
fzf-file-widget() {
  local selected_file
  selected_file=$(find . \( -type d -o -type f \) -print 2> /dev/null | fzf --height 60% --reverse --ansi \
    --preview 'eza -l --color=always --icons {}' \
    --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9,fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 \
    --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,marker:#ff79c6,spinner:#ffb86c,header:#6272a4)
  if [ -n "$selected_file" ]; then
    LBUFFER="${LBUFFER}${selected_file}"
  fi
  zle reset-prompt
}
zle -N fzf-file-widget

## fzf preview function with bat, excluding specific file types
fzf_preview() {
  local selected_file
  selected_file=$(find . -type f \( ! -name "*.png" ! -name "*.webp" ! -name "*.svg" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.gif" ! -name "*.bmp" ! -name "*.mp3" ! -name "*.wav" ! -name "*.flac" ! -name "*.ogg" ! -name "*.m4a" ! -name "*.aac" ! -name "*.wma" \) -print 2> /dev/null | fzf --height 60% --reverse --preview 'bat --style=numbers --color=always --line-range=:500 {}' --preview-window=right:60%)
  if [ -n "$selected_file" ]; then
    LBUFFER="${LBUFFER}${selected_file}"
  fi
  zle reset-prompt
}
zle -N fzf_preview

## Function to search within file contents using ripgrep and fzf
rg_fzf_preview() {
  local selected_line
  selected_line=$(rg --column --line-number --no-heading --color=always -F "$1" \
    | fzf --ansi --ezact --no-sort --preview 'bat --style=numbers --color=always --line-range=$(awk -F: "{if (\$2 > 10) {print \$2-10\":\"\$2+10} else {print \"1:\"\$2+10}}" <<< {}) --highlight-line=$(awk -F: "{print \$2}" <<< {}) $(awk -F: "{print \$1}" <<< {})' \
    --preview-window=right:60%:wrap --height=60% --border)
  if [ -n "$selected_line" ]; then
    local file=$(echo "$selected_line" | cut -d: -f1)
    local line=$(echo "$selected_line" | cut -d: -f2)
    LBUFFER+="+$line $file"
    zle reset-prompt
  fi
}
zle -N rg_fzf_preview

# User-defined aliases and functions

## Basic Aliases
alias cls='clear'               # Clear screen
alias copy='wl-copy <'          # Copy to clipboard (Wayland)

## Alias cat to bat for syntax highlighting
alias bcat='bat'

alias glg="g log --graph --decorate --all --abbrev-commit \
 --date=relative --color \
 --pretty=format:'%C(bold yellow)%h%C(reset) %C(green)%ar%C(reset) \
 %C(bold blue)%d%C(reset)%n  %s %C(dim white)– %an%C(reset)'"

alias glom="g log --format=%s"

## Functions for using bat with less, head, and tail
function bless() {
  bat --paging=always "$@"
}

function bhead() {
  local lines=10
  if [[ $1 == "-n" ]]; then
    lines=$2
    shift 2
  fi
  bat --paging=never --line-range ":$lines" "$@"
}

function btail() {
  local file=$1
  local lang=${2:-sh}
  tail -f "$file" | bat --paging=never -l "$lang"
}

# Define the yy function
function yy() {
  local tmp
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd" || return
  fi
  rm -f -- "$tmp"
  zle reset-prompt  # Force Zsh to reprocess the prompt immediately
}

## Aliases for eza (enhanced ls command)
alias ls='eza --color=auto --group-directories-first'
alias ll='eza -l --color=auto --group-directories-first'
alias la='eza -a --color=auto --group-directories-first'
alias tree='eza --tree'
alias lia='eza -la --icons --color=always'
alias liatree='eza -la --icons --color=always --tree'
alias tree1='eza --tree --level=1'
alias tree2='eza --tree --level=2'
alias tree3='eza --tree --level=3'
alias tree4='eza --tree --level=4'
alias treea='eza --tree -a'
alias treea1='eza --tree -a --level=1'
alias treea2='eza --tree -a --level=2'
alias treea3='eza --tree -a --level=3'
alias treea4='eza --tree -a --level=4'
alias liatree1='eza -la --icons --color=always --tree --level=1'
alias liatree2='eza -la --icons --color=always --tree --level=2'
alias liatree3='eza -la --icons --color=always --tree --level=3'
alias liatree4='eza -la --icons --color=always --tree --level=4'

## Alias for shutting down and updating all packages
alias shutdown='~/.local/bin/update-and-shutdown.sh'

## Alias for restarting and updating all packages
alias restart='~/.local/bin/update-and-restart.sh'

## Alias for Penguin Fetch
alias pfetch='neofetch --config ~/.local/bin/fetches/penguinfetch.conf'

# Calendar and Date-related Aliases

## Alias to get the day of the week for a specific date
alias weekday='~/.local/bin/calendar/calendar_utils.sh get_day_of_week' # Usage: weekday YYYY-MM-DD

## Alias to get dates for specific days of the week in the current month
alias daydates='~/.local/bin/calendar/calendar_utils.sh get_dates_for_days_of_week' # Usage: daydates Monday Wednesday

## Alias to calculate days between two dates
alias daysbetween='~/.local/bin/calendar/calendar_utils.sh days_between_dates' # Usage: daysbetween start_date end_date

# Use Dracula theme for fzf
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# eza color scheme definitions
export EXA_COLORS="\
uu=36:\
gu=37:\
sn=32:\
sb=32:\
da=34:\
ur=34:\
uw=35:\
ux=36:\
ue=36:\
gr=34:\
gw=35:\
gx=36:\
tr=34:\
tw=35:\
tx=36:"

# To customize prompt, run p10k configure or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $HOME/.cargo/env 2>/dev/null || true

# A safer alternative to rm
# It adds files to trash bin
alias rm='trash'

alias neofetch='fastfetch'

export PATH="$HOME/.local/bin:$HOME/go/bin:/snap/bin:$PATH"

export EDITOR='nvim'

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

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
