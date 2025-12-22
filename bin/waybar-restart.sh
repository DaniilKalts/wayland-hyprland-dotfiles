#!/usr/bin/env bash

# Waybar auto-restart script
# Ensures waybar is always running and restarts it if it crashes

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"

# Kill any existing waybar instances
killall -q waybar

# Wait for waybar to fully terminate
while pgrep -x waybar >/dev/null; do sleep 0.1; done

# Start waybar and monitor it
while true; do
    waybar -c "$CONFIG" -s "$STYLE" &
    WAYBAR_PID=$!

    # Wait for waybar process to exit
    wait $WAYBAR_PID

    # If waybar exits, wait 1 second before restarting
    # This prevents rapid restart loops if there's a config error
    sleep 1
done
