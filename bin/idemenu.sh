#!/usr/bin/env bash
set -euo pipefail

WOFI_BIN="${WOFI_BIN:-wofi}"
STYLE_FILE="${STYLE_FILE:-$HOME/.config/wofi/style.css}"

MENU_W="${MENU_W:-320}"
MENU_LINES="${MENU_LINES:-4}"

ICON_IDE=""

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "IDE Menu" "$1"
  else
    echo "IDE Menu: $1" >&2
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

if ! command -v "$WOFI_BIN" >/dev/null 2>&1; then
  notify "wofi not found."
  exit 1
fi

choice="$(wofi_menu "IDE" \
  "$ICON_IDE  Antigravity" \
  "$ICON_IDE  Cursor" \
  "$ICON_IDE  Goland" \
  "$ICON_IDE  VS Code")" || exit 0

case "$choice" in
  *"Antigravity"*)
    antigravity
    ;;
  *"Cursor"*)
    cursor
    ;;
  *"Goland"*)
    goland
    ;;
  *"VS Code"*)
    code
    ;;
  *)
    exit 0
    ;;
esac
