#!/usr/bin/env bash

log="/tmp/waybar-restart.log"

timeout 5 killall -q -w waybar || killall -q -9 waybar

# Keep waybar alive for as long as Hyprland is.
while hyprctl version >/dev/null 2>&1; do
    waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css" >> "$log" 2>&1
    sleep 1
done
