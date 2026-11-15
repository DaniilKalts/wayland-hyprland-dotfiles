#!/usr/bin/env bash
set -euo pipefail
MENU_LINES=6
source "${0%/*}/menu-lib.sh"

ICON_LOCK=""
ICON_LOGOUT="󰗽"
ICON_SUSPEND="⏾"
ICON_REBOOT=""
ICON_SHUTDOWN=""
ICON_YES=""
ICON_NO=""

confirm() {
    [[ "$(menu "Confirm: $1" "$ICON_YES  Yes" "$ICON_NO  No")" == *Yes ]]
}

suspend() {
    hyprlock &
    sleep 2
    systemctl suspend
}

choice="$(menu "Power Menu" \
    "$ICON_LOCK  Lock" \
    "$ICON_LOGOUT  Logout" \
    "$ICON_SUSPEND  Suspend" \
    "$ICON_REBOOT  Reboot" \
    "$ICON_SHUTDOWN  Shutdown")" || exit 0

case "$choice" in
    *Lock) hyprlock ;;
    *Logout) if confirm Logout; then hyprctl dispatch exit; fi ;;
    *Suspend) if confirm Suspend; then suspend; fi ;;
    *Reboot) if confirm Reboot; then systemctl reboot; fi ;;
    *Shutdown) if confirm Shutdown; then systemctl poweroff; fi ;;
esac
