#!/bin/sh

if ! response=$(herdr agent list 2>&1); then
    printf '%s\n' "$response" >&2
    printf 'Press Enter to close. '
    read -r ignored
    exit 1
fi

if ! rows=$(printf '%s\n' "$response" | jq -r '
    .result.agents[]
    | select(.pane_id != null)
    | [.pane_id, ([.name, .title, (.terminal_title_stripped // .terminal_title),
        .display_agent, .agent] | map(select(type == "string" and length > 0))
        | unique | join("  ·  "))]
    | if .[1] == "" then .[1] = .[0] else . end
    | @tsv
'); then
    printf 'Could not read the agent list. Press Enter to close. '
    read -r ignored
    exit 1
fi

header='Type to search  ·  Enter to open  ·  Esc to close'
if [ -z "$rows" ]; then
    header='No active agents  ·  Esc to close'
fi

if pane=$(printf '%s' "$rows" | FZF_DEFAULT_OPTS= FZF_DEFAULT_OPTS_FILE= fzf \
    --layout=reverse --no-multi --ignore-case --prompt='Agent ❯ ' --header="$header" \
    --delimiter="$(printf '\t')" --with-nth=2.. --accept-nth=1); then
    if ! response=$(herdr agent focus "$pane" 2>&1); then
        printf '%s\n' "$response" >&2
        printf 'Press Enter to close. '
        read -r ignored
        exit 1
    fi
fi
