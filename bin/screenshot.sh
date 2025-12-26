#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                    SCREENSHOT WITH NOTIFICATIONS                          │
# └───────────────────────────────────────────────────────────────────────────┘
# Takes screenshots with grim+satty and shows notifications with preview
# Note: Requires screenshot-watcher.sh to be running for instant notifications
#
# Usage: screenshot.sh [fullscreen|region|fullscreen-save|region-save|fullscreen-copy|region-copy]

MODE="${1:-region}"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
SCREENSHOT_DIR="$HOME/Pictures/screenshots"

# Create screenshots directory if it doesn't exist
mkdir -p "$SCREENSHOT_DIR"

case "$MODE" in
    fullscreen)
        # Fullscreen screenshot with satty annotation
        grim -l 0 - | satty --filename -
        ;;

    region)
        # Region selection screenshot with satty annotation
        grim -l 0 -g "$(slurp)" - | satty --filename -
        ;;

    fullscreen-save)
        # Fullscreen screenshot saved directly to file
        FILENAME="${SCREENSHOT_DIR}/screenshot-${TIMESTAMP}.png"
        grim -l 0 "$FILENAME"
        ;;

    region-save)
        # Region screenshot saved directly to file
        GEOMETRY=$(slurp)

        # Check if user cancelled slurp
        if [ -n "$GEOMETRY" ]; then
            FILENAME="${SCREENSHOT_DIR}/screenshot-${TIMESTAMP}.png"
            grim -l 0 -g "$GEOMETRY" "$FILENAME"
        fi
        ;;

    fullscreen-copy)
        # Fullscreen screenshot directly to clipboard with notification
        TEMP_FILE="/tmp/screenshot-${TIMESTAMP}.png"
        grim -l 0 "$TEMP_FILE"

        # Copy to clipboard
        wl-copy < "$TEMP_FILE"

        # Show notification with preview
        notify-send -a "screenshot" \
                   -u normal \
                   -i "$TEMP_FILE" \
                   "Screenshot Copied" \
                   "Fullscreen screenshot copied to clipboard"

        # Clean up after delay
        (sleep 10 && rm -f "$TEMP_FILE") &
        ;;

    region-copy)
        # Region screenshot directly to clipboard with notification
        TEMP_FILE="/tmp/screenshot-${TIMESTAMP}.png"
        GEOMETRY=$(slurp)

        # Check if user cancelled slurp
        if [ -n "$GEOMETRY" ]; then
            grim -l 0 -g "$GEOMETRY" "$TEMP_FILE"

            # Copy to clipboard
            wl-copy < "$TEMP_FILE"

            # Show notification with preview
            notify-send -a "screenshot" \
                       -u normal \
                       -i "$TEMP_FILE" \
                       "Screenshot Copied" \
                       "Region screenshot copied to clipboard"

            # Clean up after delay
            (sleep 10 && rm -f "$TEMP_FILE") &
        fi
        ;;

    *)
        echo "Usage: $0 [fullscreen|region|fullscreen-copy|region-copy]"
        exit 1
        ;;
esac
