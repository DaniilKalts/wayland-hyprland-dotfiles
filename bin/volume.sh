#!/bin/bash
# Volume control script - ensures volume is always divisible by 5

ACTION="$1"

# Get current volume (0-100)
CURRENT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')

# Round to nearest 5
ROUNDED=$(( (CURRENT + 2) / 5 * 5 ))

case "$ACTION" in
    up)
        NEW=$((ROUNDED + 5))
        [ $NEW -gt 100 ] && NEW=100
        wpctl set-volume @DEFAULT_AUDIO_SINK@ ${NEW}%
        ;;
    down)
        NEW=$((ROUNDED - 5))
        [ $NEW -lt 0 ] && NEW=0
        wpctl set-volume @DEFAULT_AUDIO_SINK@ ${NEW}%
        ;;
    toggle)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        echo "Usage: $0 {up|down|toggle}"
        exit 1
        ;;
esac
