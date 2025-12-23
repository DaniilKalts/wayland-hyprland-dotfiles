#!/usr/bin/env bash

# Waybar auto-restart script
# Ensures waybar is always running and restarts it if it crashes

CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
LOG_FILE="/tmp/waybar-restart.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Function to check if Hyprland is running
check_hyprland() {
    # Use hyprctl to check if Hyprland is accessible (more reliable than pgrep)
    if ! hyprctl version >/dev/null 2>&1; then
        log "Hyprland not accessible, exiting"
        exit 0
    fi
}

# Function to kill waybar gracefully
kill_waybar() {
    if pgrep -x waybar >/dev/null; then
        log "Killing existing waybar instances"
        killall -q waybar
        # Wait for waybar to fully terminate (max 5 seconds)
        local count=0
        while pgrep -x waybar >/dev/null && [ $count -lt 50 ]; do
            sleep 0.1
            ((count++))
        done
        # Force kill if still running
        if pgrep -x waybar >/dev/null; then
            log "Force killing waybar"
            killall -9 waybar
            sleep 0.5
        fi
    fi
}

log "Waybar restart script started"

# Initial cleanup
kill_waybar

# Start waybar and monitor it
while true; do
    # Check if Hyprland is still running
    check_hyprland

    log "Starting waybar (PID will be logged)"
    waybar -c "$CONFIG" -s "$STYLE" >> "$LOG_FILE" 2>&1 &
    WAYBAR_PID=$!
    log "Waybar started with PID: $WAYBAR_PID"

    # Wait for waybar process to exit
    wait $WAYBAR_PID
    EXIT_CODE=$?

    log "Waybar exited with code: $EXIT_CODE"

    # If waybar exits, wait before restarting
    # This prevents rapid restart loops if there's a config error
    sleep 1
done
