#!/usr/bin/env bash

# Get notification count
COUNT=$(dunstctl count waiting)

# Check if dunst is paused
IS_PAUSED=$(dunstctl is-paused)

# Determine the icon class
if [ "$IS_PAUSED" = "true" ]; then
    if [ "$COUNT" -gt 0 ]; then
        CLASS="dnd-notification"
    else
        CLASS="dnd-none"
    fi
else
    if [ "$COUNT" -gt 0 ]; then
        CLASS="notification"
    else
        CLASS="none"
    fi
fi

# Output JSON for Waybar
if [ "$COUNT" -gt 0 ]; then
    printf '{"text":"%s","class":"%s"}\n' "$COUNT" "$CLASS"
else
    printf '{"text":"","class":"%s"}\n' "$CLASS"
fi
