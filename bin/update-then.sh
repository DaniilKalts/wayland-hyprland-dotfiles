#!/usr/bin/env bash

case "${1:-}" in
    reboot | poweroff) ;;
    *) echo "Usage: update-then.sh {reboot|poweroff}" >&2; exit 1 ;;
esac

sudo pacman -Syu
sudo systemctl "$1"
