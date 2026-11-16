#!/usr/bin/env bash
# Announce screenshots saved to ~/pictures/screenshots (by screenshot.sh or satty).
set -euo pipefail

dir="$HOME/pictures/screenshots"
mkdir -p "$dir"

exec 9> "${XDG_RUNTIME_DIR:-/tmp}/screenshot-watcher.lock"
flock -n 9 || exit 0

# "changes done" fires once per file, after it is fully written.
gio monitor -d "$dir" 9>&- | while IFS= read -r event; do
    [[ "$event" == *".png: changes done" ]] || continue
    file="${event#*: }"
    file="${file%: changes done}"
    notify-send -a screenshot -i "$file" "Screenshot saved in" "~/pictures/screenshots/" || true
done
