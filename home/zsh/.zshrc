# Must stay at the top: Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
export EDITOR='nvim'
export HIST_STAMPS="%F %T"
export PNPM_HOME="$HOME/.local/share/pnpm"

typeset -U path
path=(~/.cargo/bin $PNPM_HOME ~/.npm-global/bin ~/.local/bin ~/go/bin /snap/bin $path)

export FZF_DEFAULT_OPTS='--ansi --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
export EZA_COLORS="uu=36:gu=37:sn=32:sb=32:da=34:ur=34:uw=35:ux=36:ue=36:gr=34:gw=35:gx=36:tr=34:tw=35:tx=36:"

# Dracula for zsh-syntax-highlighting; must be set before the plugin loads.
typeset -gA ZSH_HIGHLIGHT_STYLES
() {
  local color tokens token
  for color tokens in \
    '#6272A4' 'comment' \
    '#50FA7B' 'alias suffix-alias global-alias function command' \
    '#FFB86C' 'single-hyphen-option double-hyphen-option' \
    '#BD93F9' 'back-quoted-argument history-expansion' \
    '#8BE9FD' 'builtin reserved-word hashed-command' \
    '#FF79C6' 'commandseparator back-quoted-argument-delimiter back-double-quoted-argument back-dollar-quoted-argument path_pathseparator path_prefix_pathseparator' \
    '#F1FA8C' 'single-quoted-argument double-quoted-argument rc-quote' \
    '#FF5555' 'unknown-token' \
    '#F8F8F2' 'command-substitution-delimiter command-substitution-delimiter-unquoted process-substitution-delimiter dollar-quoted-argument dollar-double-quoted-argument assign named-fd numeric-fd path path_prefix globbing redirection arg0 default'
  do
    for token in ${=tokens}; do
      ZSH_HIGHLIGHT_STYLES[$token]="fg=$color"
    done
  done
}
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#50FA7B,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#FFB86C,italic'

# Dracula for the Linux console.
if [[ "$TERM" == linux ]]; then
  printf %b '\e[40m\e[8]\e[37m\e[8]' \
    '\e]P0282a36\e]P86272a4' '\e]P1ff5555\e]P9ff7777' '\e]P250fa7b\e]PA70fa9b' '\e]P3f1fa8c\e]PBffb86c' \
    '\e]P4bd93f9\e]PCcfa9ff' '\e]P5ff79c6\e]PDff88e8' '\e]P68be9fd\e]PE97e2ff' '\e]P7f8f8f2\e]PFffffff'
  clear
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-completions
  you-should-use
  zsh-history-substring-search
)

source "$ZSH/oh-my-zsh.sh"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

setopt EXTENDED_HISTORY

alias cls='clear'
alias rm='trash'
alias copy='wl-copy'
alias paste='wl-paste'
alias shutdown='~/.local/bin/update-then.sh poweroff'
alias restart='~/.local/bin/update-then.sh reboot'
alias neofetch='fastfetch'
alias tools='~/.local/bin/tools.sh'
alias learn-tools='~/.local/bin/tools.sh --learn'

alias glg="g log --graph --decorate --all --abbrev-commit --date=relative --color --pretty=format:'%C(bold yellow)%h%C(reset) %C(green)%ar%C(reset) %C(bold blue)%d%C(reset)%n  %s %C(dim white)– %an%C(reset)'"
alias glom="g log --format=%s"

alias bcat='bat'
alias ls='eza --color=auto --group-directories-first'
alias ll='eza -l --color=auto --group-directories-first'
alias la='eza -a --color=auto --group-directories-first'
alias lia='eza -la --icons --color=always'
alias tree='eza --tree --group-directories-first --sort=name'
alias treea='eza --tree -a --group-directories-first --sort=name'
alias liatree='eza -la --icons --color=always --tree --group-directories-first --sort=name'
() {
  local name level
  for name in tree treea liatree; do
    for level in 1 2 3 4; do
      alias "$name$level=${aliases[$name]} --level=$level"
    done
  done
}

bless() { bat --paging=always "$@"; }
bhead() { bat --paging=never --line-range ":${2:-10}" "$@"; }
btail() { tail -f "$1" | bat --paging=never -l "${2:-sh}"; }

jc() {
  local base="${1%.*}"
  javac "$base.java" && java "$base"
}

# cd into the directory yazi was in when it quit.
yy() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  cwd="$(<"$tmp")"
  rm -f -- "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
}

fzf-history-widget() {
  local selected
  selected=$(fc -rl 1 | awk '{$1=""; print substr($0,2)}' | fzf +s --tac) && LBUFFER=$selected
  zle redisplay
}

fzf-file-widget() {
  local selected
  selected=$(find . \( -type d -o -type f \) -print 2>/dev/null \
    | fzf --height 60% --reverse --preview 'eza -l --color=always --icons {}')
  [[ -n "$selected" ]] && LBUFFER+="$selected"
  zle reset-prompt
}

fzf_preview() {
  local selected
  selected=$(find . -type f \( ! -name "*.png" ! -name "*.webp" ! -name "*.svg" ! -name "*.jpg" ! -name "*.jpeg" ! -name "*.gif" ! -name "*.bmp" ! -name "*.mp3" ! -name "*.wav" ! -name "*.flac" ! -name "*.ogg" ! -name "*.m4a" ! -name "*.aac" ! -name "*.wma" \) -print 2>/dev/null \
    | fzf --height 60% --reverse --preview 'bat --style=numbers --color=always --line-range=:500 {}' --preview-window=right:60%)
  [[ -n "$selected" ]] && LBUFFER+="$selected"
  zle reset-prompt
}

# Search file contents for the text typed so far.
rg_fzf_preview() {
  if [[ -z "$LBUFFER" ]]; then
    zle -M "Ripgrep search: Type a query before pressing Ctrl+G"
    return 1
  fi

  local matches selected
  matches=$(rg --column --line-number --no-heading --color=always -F "$LBUFFER" 2>/dev/null)
  if [[ -z "$matches" ]]; then
    zle -M "No matches found for: '$LBUFFER'"
    return 1
  fi

  selected=$(echo "$matches" \
    | fzf --ansi --exact --no-sort --preview 'bat --style=numbers --color=always --line-range=$(awk -F: "{if ($2 > 10) {print $2-10":"$2+10} else {print \"1:\"$2+10}}" <<< {}) --highlight-line=$(awk -F: "{print $2}" <<< {}) $(awk -F: "{print $1}" <<< {})' \
      --preview-window=right:60%:wrap --height=60% --border)

  if [[ -n "$selected" ]]; then
    LBUFFER="+$(cut -d: -f2 <<< "$selected") $(cut -d: -f1 <<< "$selected")"
    RBUFFER=""
    zle redisplay
  fi
}

enter-vi-normal-mode() { zle vi-cmd-mode; }

autoload -Uz edit-command-line
zle -N edit-command-line
zle -N enter-vi-normal-mode
zle -N fzf-history-widget
zle -N fzf-file-widget
zle -N fzf_preview
zle -N rg_fzf_preview

bindkey -v
bindkey -M viins 'jk' enter-vi-normal-mode
() {
  local keymap
  for keymap in viins vicmd; do
    bindkey -M $keymap '^[a' autosuggest-accept
    bindkey -M $keymap '^R' fzf-history-widget
    bindkey -M $keymap '^F' fzf-file-widget
    bindkey -M $keymap '^P' fzf_preview
    bindkey -M $keymap '^G' rg_fzf_preview
    bindkey -M $keymap '^E' edit-command-line
  done
}
