#!/usr/bin/env bash
set -euo pipefail

color="$(hyprpicker --autocopy --format=hex)" || exit 0
[[ -n "$color" ]] || exit 0

preview="$(mktemp --suffix=.png)"
trap 'rm -f "$preview"' EXIT

magick -size 64x64 "xc:$color" "$preview"
notify-send -a color-picker -u low -t 5000 -i "$preview" "Color Copied" "<b>$color</b>"
sleep 6
