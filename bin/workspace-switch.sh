#!/usr/bin/env bash

# Circular workspace switcher for workspaces 1-7
# Usage: workspace-switch.sh [next|prev]

DIRECTION="$1"
MIN_WORKSPACE=1
MAX_WORKSPACE=7

# Get current workspace
CURRENT=$(hyprctl activeworkspace -j | jq -r '.id')

# Calculate new workspace with wrapping
if [ "$DIRECTION" = "next" ]; then
    if [ "$CURRENT" -ge "$MAX_WORKSPACE" ]; then
        NEW_WORKSPACE=$MIN_WORKSPACE
    else
        NEW_WORKSPACE=$((CURRENT + 1))
    fi
elif [ "$DIRECTION" = "prev" ]; then
    if [ "$CURRENT" -le "$MIN_WORKSPACE" ]; then
        NEW_WORKSPACE=$MAX_WORKSPACE
    else
        NEW_WORKSPACE=$((CURRENT - 1))
    fi
else
    echo "Usage: $0 [next|prev]"
    exit 1
fi

# Switch to new workspace
hyprctl dispatch workspace "$NEW_WORKSPACE"
