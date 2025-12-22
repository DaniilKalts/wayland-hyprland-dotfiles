#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                         SMART URL OPENER                                  │
# └───────────────────────────────────────────────────────────────────────────┘
# Opens URL in existing browser tab if browser is on current workspace,
# otherwise opens a new browser window.
#
# Usage: open-url.sh <url>

URL="$1"
BROWSER="firefox-developer-edition"

if [ -z "$URL" ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

# Get current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')

# Check if Firefox is running on the current workspace
BROWSER_ON_WS=$(hyprctl clients -j | jq --arg ws "$CURRENT_WS" '
    .[] | select(.workspace.id == ($ws | tonumber)) | select(.class | test("firefox"; "i"))
' | head -1)

if [ -n "$BROWSER_ON_WS" ]; then
    # Browser exists on current workspace - open in new tab
    $BROWSER "$URL" &
else
    # No browser on current workspace - open new window
    $BROWSER --new-window "$URL" &
fi
