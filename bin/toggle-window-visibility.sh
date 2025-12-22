#!/usr/bin/env bash
# Toggle visibility of all windows in the current workspace
# Windows are moved to/from a special workspace

set -euo pipefail

# Get current workspace
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Get all window addresses in the current workspace
current_windows=$(hyprctl clients -j | jq -r --arg ws "$current_workspace" '.[] | select(.workspace.id == ($ws | tonumber)) | .address')

# Special workspace name for hidden windows from this workspace
special_workspace="special:hidden_$current_workspace"

# Count windows in current workspace
window_count=$(echo "$current_windows" | grep -c "0x" || true)

if [ "$window_count" -gt 0 ]; then
    # There are windows in current workspace - hide them
    echo "$current_windows" | while read -r addr; do
        if [ -n "$addr" ]; then
            hyprctl dispatch movetoworkspacesilent "$special_workspace,address:$addr"
        fi
    done
else
    # No windows in current workspace - check if there are hidden windows to restore
    hidden_windows=$(hyprctl clients -j | jq -r --arg ws "$special_workspace" '.[] | select(.workspace.name == $ws) | .address')
    hidden_count=$(echo "$hidden_windows" | grep -c "0x" || true)

    if [ "$hidden_count" -gt 0 ]; then
        # Restore hidden windows to current workspace
        echo "$hidden_windows" | while read -r addr; do
            if [ -n "$addr" ]; then
                hyprctl dispatch movetoworkspacesilent "$current_workspace,address:$addr"
            fi
        done
    fi
fi
