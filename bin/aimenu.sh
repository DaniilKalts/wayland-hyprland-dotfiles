#!/usr/bin/env bash
set -euo pipefail

WOFI_BIN="${WOFI_BIN:-wofi}"
STYLE_FILE="${STYLE_FILE:-$HOME/.config/wofi/style.css}"

MENU_W="${MENU_W:-320}"
MENU_LINES="${MENU_LINES:-5}"

ICON_AI="󰙴"

URL_CHATGPT="https://chat.openai.com/"
URL_CLAUDE="https://claude.ai/"
URL_GEMINI="https://gemini.google.com/"
URL_PERPLEXITY="https://perplexity.ai/"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "AI Menu" "$1"
  else
    echo "AI Menu: $1" >&2
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

open_url() {
  ~/.local/bin/open-url.sh "$1"
}

if ! command -v "$WOFI_BIN" >/dev/null 2>&1; then
  notify "wofi not found."
  exit 1
fi

choice="$(wofi_menu "AI Tools" \
  "$ICON_AI  ChatGPT" \
  "$ICON_AI  Claude" \
  "$ICON_AI  Gemini" \
  "$ICON_AI  Perplexity")" || exit 0

case "$choice" in
  *"ChatGPT"*)
    open_url "$URL_CHATGPT"
    ;;
  *"Claude"*)
    open_url "$URL_CLAUDE"
    ;;
  *"Gemini"*)
    open_url "$URL_GEMINI"
    ;;
  *"Perplexity"*)
    open_url "$URL_PERPLEXITY"
    ;;
  *)
    exit 0
    ;;
esac
