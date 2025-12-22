#!/usr/bin/env bash
set -euo pipefail

WOFI_BIN="${WOFI_BIN:-wofi}"
STYLE_FILE="${STYLE_FILE:-$HOME/.config/wofi/style.css}"

MENU_W="${MENU_W:-320}"
MENU_LINES="${MENU_LINES:-6}"

ICON_LOCK=""
ICON_LOGOUT="󰗽"
ICON_SUSPEND="⏾"
ICON_REBOOT=""
ICON_SHUTDOWN=""
ICON_YES=""
ICON_NO=""

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Power" "$1"
  else
    echo "Power: $1" >&2
  fi
}

wofi_menu() {
  local prompt="$1"
  shift

  printf '%s\n' "$@" | "$WOFI_BIN" --dmenu \
    --prompt "$prompt" \
    --style "$STYLE_FILE" \
    --width "$MENU_W" \
    --lines "$MENU_LINES" \
    --columns 1 \
    --cache-file /dev/null \
    --normal-window \
    --gtk-dark
}

confirm() {
  local action="$1"
  local ans
  ans="$(wofi_menu "Confirm: $action" \
    "$ICON_YES  Yes" \
    "$ICON_NO  No")" || return 1
  [[ "$ans" == *"Yes"* ]]
}

do_lock() {
  if command -v hyprlock >/dev/null 2>&1; then
    hyprlock
    return 0
  fi
  if command -v swaylock >/dev/null 2>&1; then
    swaylock -f -c 282a36
    return 0
  fi
  if command -v loginctl >/dev/null 2>&1; then
    loginctl lock-session
    return 0
  fi
  notify "No lock utility found (hyprlock/swaylock/loginctl)."
  return 1
}

do_logout() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exit
    return 0
  fi
  notify "hyprctl not found."
  return 1
}

do_suspend() {
  # Lock before suspend (best practice for security)
  loginctl lock-session
  sleep 1

  # Suspend
  systemctl suspend
}

do_reboot() {
  systemctl reboot
}

do_shutdown() {
  systemctl poweroff
}

# Handle direct command arguments
if [ "${1:-}" = "suspend" ]; then
  do_suspend
  exit 0
fi

if ! command -v "$WOFI_BIN" >/dev/null 2>&1; then
  notify "wofi not found."
  exit 1
fi

choice="$(wofi_menu "Power Menu" \
  "$ICON_LOCK  Lock" \
  "$ICON_LOGOUT  Logout" \
  "$ICON_SUSPEND  Suspend" \
  "$ICON_REBOOT  Reboot" \
  "$ICON_SHUTDOWN  Shutdown")" || exit 0

case "$choice" in
  *"Lock"*)
    do_lock
    ;;
  *"Logout"*)
    confirm "Logout" && do_logout
    ;;
  *"Suspend"*)
    confirm "Suspend" && do_suspend
    ;;
  *"Reboot"*)
    confirm "Reboot" && do_reboot
    ;;
  *"Shutdown"*)
    confirm "Shutdown" && do_shutdown
    ;;
  *)
    exit 0
    ;;
esac
