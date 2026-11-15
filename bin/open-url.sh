#!/usr/bin/env bash
set -euo pipefail

url="${1:?Usage: open-url.sh <url>}"
browser="firefox-developer-edition"
workspace="$(hyprctl activeworkspace -j | jq '.id')"

# Reuse the browser window on this workspace, otherwise open a new one here.
if hyprctl clients -j | jq -e --argjson ws "$workspace" \
    'any(.[]; .workspace.id == $ws and (.class | test("firefox"; "i")))' >/dev/null; then
    "$browser" "$url" &
else
    "$browser" --new-window "$url" &
fi
