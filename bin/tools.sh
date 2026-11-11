#!/usr/bin/env bash

# ┌───────────────────────────────────────────────────────────────────────────┐
# │                       ALL TERMINAL TOOLS ON THIS SYSTEM                   │
# └───────────────────────────────────────────────────────────────────────────┘
# Lists every installed TUI/CLI tool, grouped by purpose.
# Usage: tools

# Dracula colors
PURPLE='\033[38;2;189;147;249m' PINK='\033[38;2;255;121;198m'
GREEN='\033[38;2;80;250;123m'   COMMENT='\033[38;2;98;114;164m'
BOLD='\033[1m' NC='\033[0m'

# Format: "Group|command|description|instead of"
TOOLS=(
    "Files & Search|yazi|file manager with previews|"
    "Files & Search|fd|find files fast|find"
    "Files & Search|rg|search text in files|grep"
    "Files & Search|fzf|fuzzy-pick anything (Ctrl+R history)|"
    "Files & Search|bat|view files with syntax colors|cat"
    "Files & Search|eza|list files with icons|ls"
    "Files & Search|trash|delete to trash, recoverable|rm"
    "Files & Search|zoxide|jump to a folder by part of its name|cd"
    "Files & Search|tree|show a folder as a tree|"
    "Files & Search|rsync|copy folders, resumable and fast|cp"
    "Files & Search|wget|download files|curl"
    "Files & Search|curl|send requests, test APIs|"
    "Files & Search|7z|extract and create 7z archives|"
    "Files & Search|unzip|extract zip files|"
    "Files & Search|zip|create zip files|"

    "Disk|dust|see what takes space|du"
    "Disk|ncdu|browse and clean disk usage|du"

    "Git|tig|browse history, diffs, blame|git log"
    "Git|delta|readable side-by-side diffs|diff"
    "Git|gh|GitHub PRs, issues, repos|"
    "Git|git-filter-repo|rewrite history (remove files, secrets)|git filter-branch"

    "System|btop|CPU, RAM, processes|top"
    "System|htop|simple process manager|top"
    "System|inxi|hardware summary (inxi -Fxz)|"
    "System|ps_mem|real RAM use per app|"
    "System|lsof|what uses a file or port (lsof -i :3000)|"
    "System|acpi|battery and temperature (acpi -bt)|"
    "System|killall|kill a program by name|kill"
    "System|fastfetch|system summary with logo|neofetch"
    "System|neofetch|system summary with logo|"
    "System|dunstctl|control notifications|"
    "System|hyprpicker|pick any color on screen|"
    "System|brightnessctl|screen brightness|"

    "Network & Devices|nmtui|connect to Wi-Fi|"
    "Network & Devices|bluetui|pair Bluetooth devices|"
    "Network & Devices|nload|live network traffic|"
    "Network & Devices|nmap|scan hosts and ports|"

    "Containers|lazydocker|manage containers, logs, images|docker ps"
    "Containers|dive|inspect Docker image layers|"
    "Containers|docker|Docker CLI|"
    "Containers|kubectl|control Kubernetes clusters|"

    "Code & Docs|tldr|short command examples|man"
    "Code & Docs|glow|read Markdown nicely|cat"
    "Code & Docs|tokei|count lines of code|"
    "Code & Docs|jq|query and format JSON|"
    "Code & Docs|chafa|view images in the terminal|"

    "AI|claude|Claude Code, AI coding agent in the terminal|"
    "AI|codex|OpenAI Codex, AI coding agent|"
    "AI|gemini|Gemini CLI, Google AI in the terminal|"
    "AI|opencode|open-source AI coding agent|"

    "Editors|nvim|Neovim, your main editor|vim"
    "Editors|vim|classic editor, for quick edits|"
    "Editors|nano|simple editor, for quick edits|"

    "Terminal|tmux|split panes, keep sessions alive|screen"
    "Terminal|stow|link dotfiles into place|"

    "Dev|npm|JavaScript package manager|"
    "Dev|pnpm|faster, disk-saving npm|npm"
    "Dev|go|Go compiler and tools|"
    "Dev|go-task|run tasks from Taskfile.yml|make"
    "Dev|rustup|Rust toolchain manager|"
    "Dev|python|Python interpreter|"
    "Dev|cmake|build C and C++ projects|make"
    "Dev|tree-sitter|parse code (used by Neovim)|"
    "Dev|silicon|code to image screenshot|"

    "Databases|psql|PostgreSQL shell|"

    "Packages|reflector|pick the fastest Arch mirrors|"
    "Packages|paccache|clear old packages (paccache -r)|"
    "Packages|debtap|convert .deb packages to Arch|"

    "Audio & Media|wpctl|audio devices and volume (wpctl status)|"
    "Audio & Media|playerctl|control music and video|"
    "Audio & Media|alsamixer|audio levels per device|"
    "Audio & Media|cava|audio visualizer|"

    "Screenshots & Images|grim|take screenshots|"
    "Screenshots & Images|slurp|select a screen region|"
    "Screenshots & Images|satty|annotate screenshots|"
    "Screenshots & Images|magick|edit and convert images|"
    "Screenshots & Images|resvg|render SVG to PNG|"
    "Screenshots & Images|pdftotext|extract text from PDF|"

    "Clipboard|wl-copy|copy text: echo hi, then wl-copy  (file: wl-copy < file.txt)|"
    "Clipboard|wl-paste|paste clipboard here: wl-paste  (in kitty: Ctrl+Shift+V)|"
    "Clipboard|cliphist|clipboard history (cliphist list)|"

    "Fun|tty-clock|big clock (tty-clock -c)|"
    "Fun|cmatrix|Matrix rain|"
    "Fun|figlet|big text (figlet hi)|"
    "Fun|toilet|big colored text (toilet hi)|"
    "Fun|cowsay|a cow says your text|"
    "Fun|lolcat|rainbow colors for any text|"
    "Fun|sl|steam train across the terminal (you typed ls by mistake)|ls"
)

is_installed() {
    command -v "$1" &>/dev/null
}

echo -e "\n${PURPLE}${BOLD}  󰙨  All terminal tools on this system${NC}  ${COMMENT}(installed only)${NC}"

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
