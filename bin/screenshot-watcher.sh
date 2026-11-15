#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

dir="$HOME/pictures/screenshots"
pidfile="/tmp/screenshot-watcher.pid"

if [[ -f "$pidfile" ]] && kill -0 "$(<"$pidfile")" 2>/dev/null; then
    exit 0
fi
echo $$ > "$pidfile"
mkdir -p "$dir"

declare -A seen
for file in "$dir"/*.png; do
    seen["$file"]=1
done

while sleep 0.5; do
    for file in "$dir"/*.png; do
        [[ -n "${seen[$file]:-}" ]] && continue
        seen["$file"]=1
        notify-send -a screenshot -i "$file" "Screenshot saved in" "~/pictures/screenshots/" || true
    done
done
