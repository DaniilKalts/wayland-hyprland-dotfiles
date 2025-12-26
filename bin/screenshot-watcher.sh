#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                    SCREENSHOT WATCHER DAEMON                              │
# └───────────────────────────────────────────────────────────────────────────┘
# Watches for new screenshots and sends notifications immediately

SCREENSHOT_DIR="$HOME/Pictures/screenshots"
WATCH_FILE="/tmp/screenshot-watcher.pid"

# Check if already running
if [ -f "$WATCH_FILE" ]; then
    OLD_PID=$(cat "$WATCH_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "Watcher already running (PID: $OLD_PID)"
        exit 0
    fi
fi

# Save our PID
echo $$ > "$WATCH_FILE"

# Create screenshots directory
mkdir -p "$SCREENSHOT_DIR"

# Keep track of known files
declare -A seen_files
for file in "$SCREENSHOT_DIR"/*.png; do
    [ -f "$file" ] && seen_files["$file"]=1
done

echo "Screenshot watcher started (PID: $$)"

# Watch for new files
while true; do
    for file in "$SCREENSHOT_DIR"/*.png; do
        [ -f "$file" ] || continue

        # If this is a new file we haven't seen before
        if [ -z "${seen_files[$file]}" ]; then
            seen_files["$file"]=1
            filename=$(basename "$file")

            # Send notification with screenshot preview
            notify-send -a "screenshot" \
                       -u normal \
                       -i "$file" \
                       "Screenshot saved in" \
                       "~/Pictures/screenshots/"
        fi
    done

    sleep 0.5  # Check twice per second
done
