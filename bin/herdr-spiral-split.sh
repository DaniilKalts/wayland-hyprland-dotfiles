#!/usr/bin/env bash
# Hyprland-dwindle-style split for herdr: always split the newest (bottom-right) pane,
# alternating right (vertical) / down (horizontal).
set -euo pipefail
layout=$(herdr pane layout | jq '.result.layout')
count=$(jq '.panes | length' <<<"$layout")
target=$(jq -r '.panes | max_by([.rect.x + .rect.y, .rect.x]) | .pane_id' <<<"$layout")
if (( count % 2 == 1 )); then dir=right; else dir=down; fi
herdr pane split "$target" --direction "$dir" --focus >/dev/null
