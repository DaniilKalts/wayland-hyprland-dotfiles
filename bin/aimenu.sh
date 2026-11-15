#!/usr/bin/env bash
set -euo pipefail
source "${0%/*}/menu-lib.sh"

icon="󰙴"
open() { exec "${0%/*}/open-url.sh" "$1"; }

choice="$(menu "AI Tools" "$icon  ChatGPT" "$icon  Claude" "$icon  Gemini" "$icon  Perplexity")" || exit 0

case "$choice" in
    *ChatGPT) open "https://chat.openai.com/" ;;
    *Claude) open "https://claude.ai/" ;;
    *Gemini) open "https://gemini.google.com/" ;;
    *Perplexity) open "https://perplexity.ai/" ;;
esac
