#!/usr/bin/env bash
# Toggle visibility of all windows in the current workspace
# Windows are moved to/from a special workspace
# Usage: toggle-window-visibility.sh [hide|show|toggle]

set -euo pipefail

# Get action from argument (default: toggle)
action="${1:-toggle}"

# Get current workspace
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Get all window addresses in the current workspace
current_windows=$(hyprctl clients -j | jq -r --arg ws "$current_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | .address')

# Special workspace name for hidden windows from this workspace
special_workspace="special:hidden_$current_workspace"

# Count windows in current workspace
window_count=$(echo "$current_windows" | grep -c "0x" || true)

# Function to hide windows
hide_windows() {
    if [ "$window_count" -gt 0 ]; then
        echo "$current_windows" | while read -r addr; do
            if [ -n "$addr" ]; then
                hyprctl dispatch movetoworkspacesilent "$special_workspace,address:$addr"
            fi
        done
    fi
}

# Function to show windows
show_windows() {
    hidden_windows=$(hyprctl clients -j | jq -r --arg ws "$special_workspace" '.[] | select(.workspace.name == $ws) | .address')
    hidden_count=$(echo "$hidden_windows" | grep -c "0x" || true)

    if [ "$hidden_count" -gt 0 ]; then
        echo "$hidden_windows" | while read -r addr; do
            if [ -n "$addr" ]; then
                hyprctl dispatch movetoworkspacesilent "$current_workspace,address:$addr"
            fi
        done
    fi
}

# Execute action
case "$action" in
    hide)
        hide_windows
        ;;
    show)
        show_windows
        ;;
    toggle)
        if [ "$window_count" -gt 0 ]; then
            hide_windows
        else
            show_windows
        fi
        ;;
    *)
        echo "Usage: $0 [hide|show|toggle]"
        exit 1
        ;;
esac
