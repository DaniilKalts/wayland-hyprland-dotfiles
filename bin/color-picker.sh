#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                      COLOR PICKER WITH NOTIFICATION                       │
# └───────────────────────────────────────────────────────────────────────────┘
# Picks a color and shows a notification with the hex code

# Pick color and copy to clipboard
COLOR=$(hyprpicker --autocopy --format=hex)

# Check if color was picked (user didn't cancel)
if [ -n "$COLOR" ]; then
    # Create a temporary color preview image
    TEMP_IMG="/tmp/color_preview_${COLOR//\#/}.png"

    # Create a 64x64 color preview using imagemagick (small square)
    if command -v magick &> /dev/null; then
        magick -size 64x64 "xc:$COLOR" "$TEMP_IMG" 2>/dev/null

        # Send notification with color preview
        notify-send -a "color-picker" \
                   -u low \
                   -i "$TEMP_IMG" \
                   "Color Copied" \
                   "<b>$COLOR</b>" \
                   -t 5000

        # Clean up after notification timeout
        sleep 6 && rm -f "$TEMP_IMG" &
    else
        # Fallback notification without preview
        notify-send -a "color-picker" \
                   -u low \
                   "Color Copied" \
                   "<b>$COLOR</b>" \
                   -t 5000
    fi
fi
