#!/usr/bin/env bash
set -euo pipefail

usage="Usage: toggle-window-visibility.sh [hide|show|toggle]"
workspace="$(hyprctl activeworkspace -j | jq -r '.id')"
hidden="special:hidden_$workspace"
visible="$(hyprctl clients -j | jq -r --argjson id "$workspace" '.[] | select(.workspace.id == $id) | .address')"

move_to() {
    local address
    while read -r address; do
        [[ -z "$address" ]] || hyprctl dispatch movetoworkspacesilent "$1,address:$address"
    done
}

hide() {
    move_to "$hidden" <<< "$visible"
}

show() {
    hyprctl clients -j \
        | jq -r --arg ws "$hidden" '.[] | select(.workspace.name == $ws) | .address' \
        | move_to "$workspace"
}

case "${1:-toggle}" in
    hide) hide ;;
    show) show ;;
    toggle) if [[ -n "$visible" ]]; then hide; else show; fi ;;
    *) echo "$usage" >&2; exit 1 ;;
esac
