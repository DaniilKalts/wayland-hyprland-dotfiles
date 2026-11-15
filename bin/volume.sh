#!/usr/bin/env bash
set -euo pipefail

sink="@DEFAULT_AUDIO_SINK@"
step=5

set_volume() {
    wpctl set-volume "$sink" "$(( $1 < 0 ? 0 : $1 > 100 ? 100 : $1 ))%"
}

current="$(wpctl get-volume "$sink" | awk '{print int($2 * 100)}')"
rounded=$(( (current + step / 2) / step * step ))

case "${1:-}" in
    up) set_volume $(( rounded + step )) ;;
    down) set_volume $(( rounded - step )) ;;
    toggle) wpctl set-mute "$sink" toggle ;;
    *) echo "Usage: volume.sh {up|down|toggle}" >&2; exit 1 ;;
esac
