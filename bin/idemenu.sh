#!/usr/bin/env bash
set -euo pipefail
MENU_LINES=4
source "${0%/*}/menu-lib.sh"

choice="$(menu "IDE" "  Antigravity" "  Cursor" "  Goland" "  VS Code")" || exit 0

case "$choice" in
    *Antigravity) exec antigravity ;;
    *Cursor) exec cursor ;;
    *Goland) exec goland ;;
    *"VS Code") exec code ;;
esac
