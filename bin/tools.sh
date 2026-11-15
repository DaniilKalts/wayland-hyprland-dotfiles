#!/usr/bin/env bash
# Usage: tools.sh [--learn|--boot]
#   --learn  only the tools worth learning
#   --boot   two random tips, once per boot

PURPLE='\033[38;2;189;147;249m' PINK='\033[38;2;255;121;198m'
GREEN='\033[38;2;80;250;123m'   CYAN='\033[38;2;139;233;253m'
COMMENT='\033[38;2;98;114;164m' BOLD='\033[1m' NC='\033[0m'

# Group|command|description|instead of|learn
TOOLS=(
    "Files & Search|yazi|file manager with previews||"
    "Files & Search|fd|find files fast|find|learn"
    "Files & Search|rg|search text in files|grep|"
    "Files & Search|fzf|fuzzy-pick anything (Ctrl+R history)||learn"
    "Files & Search|bat|view files with syntax colors|cat|"
    "Files & Search|eza|list files with icons|ls|"
    "Files & Search|trash|delete to trash, recoverable|rm|"
    "Files & Search|zoxide|jump to a folder by part of its name|cd|"
    "Files & Search|tree|show a folder as a tree||"
    "Files & Search|rsync|copy folders, resumable and fast|cp|learn"
    "Files & Search|wget|download files|curl|learn"
    "Files & Search|curl|send requests, test APIs||learn"
    "Files & Search|7z|extract and create 7z archives||"
    "Files & Search|unzip|extract zip files||"
    "Files & Search|zip|create zip files||"

    "Disk|dust|see what takes space|du|learn"
    "Disk|ncdu|browse and clean disk usage|du|learn"

    "Git|tig|browse history, diffs, blame|git log|learn"
    "Git|delta|readable side-by-side diffs|diff|learn"
    "Git|gh|GitHub PRs, issues, repos||learn"
    "Git|git-filter-repo|rewrite history (remove files, secrets)|git filter-branch|learn"

    "System|btop|CPU, RAM, processes|top|"
    "System|htop|simple process manager|top|"
    "System|inxi|hardware summary (inxi -Fxz)||learn"
    "System|ps_mem|real RAM use per app||learn"
    "System|lsof|what uses a file or port (lsof -i :3000)||learn"
    "System|acpi|battery and temperature (acpi -bt)||learn"
    "System|killall|kill a program by name|kill|"
    "System|fastfetch|system summary with logo|neofetch|"
    "System|neofetch|system summary with logo||"
    "System|dunstctl|control notifications||"
    "System|hyprpicker|pick any color on screen||"
    "System|brightnessctl|screen brightness||"

    "Network & Devices|nmtui|connect to Wi-Fi||learn"
    "Network & Devices|bluetui|pair Bluetooth devices||learn"
    "Network & Devices|nload|live network traffic||learn"
    "Network & Devices|nmap|scan hosts and ports||learn"

    "Containers|lazydocker|manage containers, logs, images|docker ps|learn"
    "Containers|dive|inspect Docker image layers||learn"
    "Containers|docker|Docker CLI||"
    "Containers|kubectl|control Kubernetes clusters||"

    "Code & Docs|tldr|short command examples|man|"
    "Code & Docs|glow|read Markdown nicely|cat|learn"
    "Code & Docs|tokei|count lines of code||learn"
    "Code & Docs|jq|query and format JSON||learn"
    "Code & Docs|chafa|view images in the terminal||learn"

    "AI|claude|Claude Code, AI coding agent in the terminal||"
    "AI|codex|OpenAI Codex, AI coding agent||"
    "AI|gemini|Gemini CLI, Google AI in the terminal||"
    "AI|opencode|open-source AI coding agent||"

    "Editors|nvim|Neovim, your main editor|vim|"
    "Editors|vim|classic editor, for quick edits||"
    "Editors|nano|simple editor, for quick edits||"

    "Terminal|tmux|split panes, keep sessions alive|screen|"
    "Terminal|stow|link dotfiles into place||learn"

    "Dev|npm|JavaScript package manager||"
    "Dev|pnpm|faster, disk-saving npm|npm|"
    "Dev|go|Go compiler and tools||"
    "Dev|go-task|run tasks from Taskfile.yml|make|"
    "Dev|rustup|Rust toolchain manager||learn"
    "Dev|python|Python interpreter||"
    "Dev|cmake|build C and C++ projects|make|"
    "Dev|tree-sitter|parse code (used by Neovim)||"
    "Dev|silicon|code to image screenshot||"

    "Databases|psql|PostgreSQL shell||"

    "Packages|reflector|pick the fastest Arch mirrors||learn"
    "Packages|paccache|clear old packages (paccache -r)||learn"
    "Packages|debtap|convert .deb packages to Arch||learn"

    "Audio & Media|wpctl|audio devices and volume (wpctl status)||"
    "Audio & Media|playerctl|control music and video||"
    "Audio & Media|alsamixer|audio levels per device||"
    "Audio & Media|cava|audio visualizer||"

    "Screenshots & Images|grim|take screenshots||"
    "Screenshots & Images|slurp|select a screen region||"
    "Screenshots & Images|satty|annotate screenshots||"
    "Screenshots & Images|magick|edit and convert images||"
    "Screenshots & Images|resvg|render SVG to PNG||learn"
    "Screenshots & Images|pdftotext|extract text from PDF||"

    "Clipboard|wl-copy|copy text: echo hi, then wl-copy  (file: wl-copy < file.txt)||learn"
    "Clipboard|wl-paste|paste clipboard here: wl-paste  (in kitty: Ctrl+Shift+V)||learn"
    "Clipboard|cliphist|clipboard history (cliphist list)||learn"

    "Fun|tty-clock|big clock (tty-clock -c)||"
    "Fun|cmatrix|Matrix rain||"
    "Fun|figlet|big text (figlet hi)||"
    "Fun|toilet|big colored text (toilet hi)||"
    "Fun|cowsay|a cow says your text||"
    "Fun|lolcat|rainbow colors for any text||"
    "Fun|sl|steam train across the terminal (you typed ls by mistake)|ls|"
)

mode="${1:-}"

entries=()
for entry in "${TOOLS[@]}"; do
    IFS='|' read -r _ cmd _ _ learn <<< "$entry"
    [[ -z "$mode" || -n "$learn" ]] || continue
    command -v "$cmd" &>/dev/null && entries+=("$entry")
done

print_tool() {
    local cmd="$1" desc="$2" instead="$3"
    local line="    ${GREEN}$(printf '%-11s' "$cmd")${NC} ${desc}"
    [[ -n "$instead" ]] && line+=" ${COMMENT}← instead of ${instead}${NC}"
    echo -e "$line"
}

if [[ "$mode" == "--boot" ]]; then
    stamp="${XDG_CACHE_HOME:-$HOME/.cache}/tools-tips-boot"
    boot_id="$(< /proc/sys/kernel/random/boot_id)"
    [[ "$(cat "$stamp" 2>/dev/null)" == "$boot_id" ]] && exit 0
    mkdir -p "${stamp%/*}"
    echo "$boot_id" > "$stamp"

    echo -e "\n  ${CYAN}💡 Tips for this session${NC}"
    printf '%s\n' "${entries[@]}" | shuf -n 2 | while IFS='|' read -r _ cmd desc _; do
        print_tool "$cmd" "$desc" ""
    done
    echo
    exit 0
fi

if [[ "$mode" == "--learn" ]]; then
    echo -e "\n${PURPLE}${BOLD}  󰙨  Tools to learn${NC}  ${COMMENT}(run 'learn-tools' anytime)${NC}"
else
    echo -e "\n${PURPLE}${BOLD}  󰙨  All terminal tools on this system${NC}  ${COMMENT}(installed only)${NC}"
fi

current=""
for entry in "${entries[@]}"; do
    IFS='|' read -r group cmd desc instead _ <<< "$entry"
    if [[ "$group" != "$current" ]]; then
        echo -e "\n  ${PINK}${BOLD}${group}${NC}"
        current="$group"
    fi
    print_tool "$cmd" "$desc" "$instead"
done
echo
