menu() {
    local prompt="$1"
    shift
    printf '%s\n' "$@" | wofi --dmenu \
        --prompt "$prompt" \
        --style "$HOME/.config/wofi/style.css" \
        --width 320 \
        --lines "${MENU_LINES:-5}" \
        --columns 1 \
        --cache-file /dev/null \
        --normal-window \
        --gtk-dark
}
