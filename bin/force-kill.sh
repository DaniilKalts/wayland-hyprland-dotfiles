#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                      FORCE KILL ACTIVE WINDOW                             │
# └───────────────────────────────────────────────────────────────────────────┘
# Force kills the currently focused window using SIGKILL

# Get the PID of the active window
PID=$(hyprctl activewindow -j | jq '.pid')

if [ -n "$PID" ] && [ "$PID" != "null" ] && [ "$PID" -gt 0 ] 2>/dev/null; then
    kill -9 "$PID" 2>/dev/null
fi
