#!/usr/bin/env bash
set -euo pipefail

usage="Usage: screenshot.sh [fullscreen|region][-save|-copy]"
mode="${1:-region}"
dir="$HOME/pictures/screenshots"
mkdir -p "$dir"

capture() {
    local target="$1" output="$2" monitor geometry
    if [[ "$target" == fullscreen ]]; then
        if ! monitor="$(hyprctl monitors -j | jq -er 'first(.[] | select(.focused)) | .name')"; then
            notify-send -u critical "Screenshot failed" "Could not determine the focused monitor."
            return 1
        fi
        grim -o "$monitor" -l 0 "$output"
    else
        geometry="$(slurp)" || return 1
        grim -g "$geometry" -l 0 "$output"
    fi
}

copy() {
    local file
    file="$(mktemp --suffix=.png)"
    if ! capture "$1" "$file"; then
        rm -f "$file"
        exit 1
    fi
    wl-copy < "$file"
    notify-send -a screenshot -i "$file" "Screenshot Copied" "${1^} screenshot copied to clipboard"
    (sleep 10 && rm -f "$file") &
}

# Saved files are announced by screenshot-watcher.sh.
case "$mode" in
    fullscreen | region) capture "$mode" - | satty --filename - ;;
    fullscreen-save | region-save) capture "${mode%-save}" "$dir/screenshot-$(date +%Y%m%d-%H%M%S).png" ;;
    fullscreen-copy | region-copy) copy "${mode%-copy}" ;;
    *) echo "$usage" >&2; exit 1 ;;
esac
