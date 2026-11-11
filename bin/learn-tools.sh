#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                         LEARN TOOLS CHEAT SHEET                        │
# └───────────────────────────────────────────────────────────────────────────┘
# Shows installed TUI/CLI tools grouped by purpose.
# Usage: learn-tools.sh          full cheat sheet (run 'learn-tools')
#        learn-tools.sh --boot   two tips, only in the first terminal after each boot


# Dracula colors
PURPLE='\033[38;2;189;147;249m' PINK='\033[38;2;255;121;198m'
GREEN='\033[38;2;80;250;123m'   CYAN='\033[38;2;139;233;253m'
COMMENT='\033[38;2;98;114;164m' BOLD='\033[1m' NC='\033[0m'

# Format: "Group|command|description|instead of"
TOOLS=(
    "Files & Search|fd|find files fast|find"
    "Files & Search|fzf|fuzzy-pick anything (Ctrl+R history)|"

    "Disk|dust|see what takes space|du"
    "Disk|ncdu|browse and clean disk usage|du"

    "Git|tig|browse history, diffs, blame|git log"
    "Git|delta|readable side-by-side diffs|diff"
    "Git|gh|GitHub PRs, issues, repos|"

    "System|inxi|hardware summary (inxi -Fxz)|"
    "System|ps_mem|real RAM use per app|"
    "System|lsof|what uses a file or port (lsof -i :3000)|"
    "System|acpi|battery and temperature (acpi -bt)|"

    "Network & Devices|nmtui|connect to Wi-Fi|"
    "Network & Devices|bluetui|pair Bluetooth devices|"
    "Network & Devices|nload|live network traffic|"
    "Network & Devices|nmap|scan hosts and ports|"

    "Containers|lazydocker|manage containers, logs, images|docker ps"
    "Containers|dive|inspect Docker image layers|"

    "Code & Docs|glow|read Markdown nicely|cat"
    "Code & Docs|tokei|count lines of code|"
    "Code & Docs|jq|query and format JSON|"
    "Code & Docs|chafa|view images in the terminal|"




    "Terminal|stow|link dotfiles into place|"

    "Files & Search|rsync|copy folders, resumable and fast|cp"
    "Files & Search|wget|download files|curl"
    "Files & Search|curl|send requests, test APIs|"

    "Git|git-filter-repo|rewrite history (remove files, secrets)|git filter-branch"

    "Dev|rustup|Rust toolchain manager|"



    "System|reflector|pick the fastest Arch mirrors|"
    "System|paccache|clear old packages (paccache -r)|"
    "System|debtap|convert .deb packages to Arch|"


    "Screenshots & Images|resvg|render SVG to PNG|"

    "Clipboard|wl-copy|copy text: echo hi, then wl-copy  (file: wl-copy < file.txt)|"
    "Clipboard|wl-paste|paste clipboard here: wl-paste  (in kitty: Ctrl+Shift+V)|"
    "Clipboard|cliphist|clipboard history (cliphist list)|"
)

is_installed() {
    local check="$1"
    [[ "$check" == "z" ]] && check="zoxide"
    command -v "$check" &>/dev/null
}

if [[ "${1:-}" == "--boot" ]]; then
    BOOT_ID="$(cat /proc/sys/kernel/random/boot_id)"
    BOOT_STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/tools-tips-boot"
    [[ "$(cat "$BOOT_STAMP" 2>/dev/null)" == "$BOOT_ID" ]] && exit 0
    mkdir -p "$(dirname "$BOOT_STAMP")"
    echo "$BOOT_ID" > "$BOOT_STAMP"

    # Two random tips from tools that are actually installed
    shown=0
    for _ in {1..200}; do
        (( shown == 2 )) && break
        IFS='|' read -r _ cmd desc _ <<< "${TOOLS[RANDOM % ${#TOOLS[@]}]}"
        is_installed "$cmd" || continue
        (( shown == 0 )) && echo -e "\n  ${CYAN}💡 Tips for this session${NC}"
        echo -e "    ${GREEN}$(printf '%-11s' "$cmd")${NC} ${desc}"
        shown=$((shown + 1))
    done
    echo ""
    exit 0
fi

echo -e "\n${PURPLE}${BOLD}  󰙨  Tools to learn${NC}  ${COMMENT}(run 'learn-tools' anytime)${NC}"

# Print each group once, in the order it first appears
groups=()
for entry in "${TOOLS[@]}"; do
    g="${entry%%|*}"
    [[ " ${groups[*]} " == *" $g "* ]] || groups+=("$g")
done

for group in "${groups[@]}"; do
    header_shown=false
    for entry in "${TOOLS[@]}"; do
        IFS='|' read -r g cmd desc instead <<< "$entry"
        [[ "$g" == "$group" ]] || continue

        is_installed "$cmd" || continue

        if [[ "$header_shown" == false ]]; then
            echo -e "\n  ${PINK}${BOLD}${group}${NC}"
            header_shown=true
        fi

        line="    ${GREEN}$(printf '%-11s' "$cmd")${NC} ${desc}"
        [[ -n "$instead" ]] && line+=" ${COMMENT}← instead of ${instead}${NC}"
        echo -e "$line"
    done
done

echo ""
