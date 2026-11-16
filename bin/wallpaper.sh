#!/usr/bin/env bash
# Set the wallpaper last chosen in waypaper, falling back to the default one.
set -euo pipefail

config="${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"
wallpaper="$(sed -n 's/^wallpaper *= *//p' "$config" 2>/dev/null || true)"
wallpaper="${wallpaper/#\~/$HOME}"
[[ -f "$wallpaper" ]] || wallpaper="$HOME/pictures/wallpapers/arch.png"

exec swaybg -i "$wallpaper" -m fill
