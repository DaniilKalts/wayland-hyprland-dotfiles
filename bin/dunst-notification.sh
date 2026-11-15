#!/usr/bin/env bash

count="$(dunstctl count waiting)"
text=""
class="none"

if (( count > 0 )); then
    text="$count"
    class="notification"
fi
[[ "$(dunstctl is-paused)" == true ]] && class="dnd-$class"

printf '{"text":"%s","class":"%s"}\n' "$text" "$class"
