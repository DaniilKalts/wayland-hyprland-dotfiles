#!/usr/bin/env bash
set -e

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗       ║
# ║  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗      ║
# ║  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║      ║
# ║  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║      ║
# ║  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝      ║
# ║  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝       ║
# ║                                                                           ║
# ║                    Wayland/Hyprland Rice Installer                        ║
# ║                         Author: Daniil Kalts                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

# Prevent running as root
[[ "$EUID" -eq 0 ]] && echo "Do not run as root!" && exit 1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ----------------------------------------------------------------------------
# Colors & Helpers
# ----------------------------------------------------------------------------

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m'
BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' NC='\033[0m'

header()  { echo -e "\n${PURPLE}══════════════════════════════════════════════════════════════${NC}\n${CYAN}  $1${NC}\n${PURPLE}══════════════════════════════════════════════════════════════${NC}\n"; }
step()    { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
err()     { echo -e "${RED}[✗]${NC} $1"; }

# Backup file/dir if it exists and is not a symlink
backup() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        warn "Backing up $target"
        mv "$target" "$target.bak.$(date +%s)"
    elif [[ -L "$target" ]]; then
        rm -f "$target"
    fi
}

# Clone repo if directory doesn't exist
clone_if_missing() {
    local url="$1" dest="$2" name="$3"
    if [[ -d "$dest" ]]; then
        warn "$name already installed, skipping..."
    else
        step "Installing $name..."
        git clone "$url" "$dest"
        success "$name installed!"
    fi
}

# ----------------------------------------------------------------------------
# Welcome
# ----------------------------------------------------------------------------

clear
echo -e "${PURPLE}"
cat << "EOF"
  ╔═══════════════════════════════════════════════════════════════════════╗
  ║  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗      █████╗ ███╗   ██╗██████╗   ║
  ║  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔══██╗  ║
  ║  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     ███████║██╔██╗ ██║██║  ██║  ║
  ║  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══██║██║╚██╗██║██║  ██║  ║
  ║  ██║  ██║   ██║   ██║     ██║  ██║███████╗██║  ██║██║ ╚████║██████╔╝  ║
  ║  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝   ║
  ╚═══════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
echo -e "${CYAN}Welcome to the Hyprland Rice Installer!${NC}"
echo -e "${YELLOW}This will install and configure your Wayland/Hyprland setup.${NC}\n"
read -p "Press Enter to continue or Ctrl+C to cancel..."

# ----------------------------------------------------------------------------
# 1. System Update
# ----------------------------------------------------------------------------

header "1/16 - Updating System"
step "Updating package database..."
sudo pacman -Syu --noconfirm
success "System updated!"

# ----------------------------------------------------------------------------
# 2. Install Yay
# ----------------------------------------------------------------------------

header "2/16 - Installing Yay (AUR Helper)"
if command -v yay &>/dev/null; then
    warn "Yay already installed, skipping..."
else
    step "Installing dependencies..."
    sudo pacman -S --needed --noconfirm base-devel git
    step "Building yay..."
    git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
    (cd /tmp/yay-git && makepkg -si --noconfirm)
    rm -rf /tmp/yay-git
    success "Yay installed!"
fi

# ----------------------------------------------------------------------------
# 3. Install Pacman Packages
# ----------------------------------------------------------------------------

header "3/16 - Installing Pacman Packages"

PACMAN_PACKAGES=(
    # Hyprland & Wayland
    hyprland waybar dunst swaybg wofi wl-clipboard cliphist
    polkit-gnome xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

    # Terminal & Dev Tools
    kitty neovim git stow ripgrep fzf bat jq

    # File Management
    thunar zip unzip wget

    # Audio
    pipewire pipewire-pulse wireplumber pavucontrol playerctl

    # Screenshots & Media
    grim slurp imagemagick obs-studio brightnessctl

    # Applications
    telegram-desktop obsidian zathura zathura-pdf-mupdf

    # System Utilities
    btop fastfetch tmux zsh eza trash-cli libnotify qt5-wayland qt6-wayland

    # Fonts & Icons
    noto-fonts-emoji papirus-icon-theme otf-font-awesome ttf-nerd-fonts-symbols-mono
)

step "Installing ${#PACMAN_PACKAGES[@]} packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
success "Pacman packages installed!"

# ----------------------------------------------------------------------------
# 3.1 Install lazy.nvim
# ----------------------------------------------------------------------------

header "3.1/16 - Installing lazy.nvim"
LAZY_DIR="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [[ -d "$LAZY_DIR" ]]; then
    warn "lazy.nvim already installed, skipping..."
else
    step "Cloning lazy.nvim..."
    mkdir -p "$(dirname "$LAZY_DIR")"
    git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git "$LAZY_DIR"
    success "lazy.nvim installed!"
fi

# ----------------------------------------------------------------------------
# 4. Install AUR Packages
# ----------------------------------------------------------------------------

header "4/16 - Installing AUR Packages"

AUR_PACKAGES=(hyprpicker hyprlock hypridle cava yazi dracula-cursors-git dracula-gtk-theme)

step "Installing ${#AUR_PACKAGES[@]} AUR packages..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
success "AUR packages installed!"

# ----------------------------------------------------------------------------
# 4.1. Activate Dracula GTK Theme & Icons
# ----------------------------------------------------------------------------

header "4.1/16 - Activating Dracula GTK Theme & Icons"

# Install Dracula Icon Theme
ICON_DIR="$HOME/.icons"
if [[ -d "$ICON_DIR/Dracula" ]]; then
    warn "Dracula icons already installed, skipping..."
else
    step "Downloading Dracula icon theme..."
    TEMP_DIR=$(mktemp -d)
    curl -fsSL -o "$TEMP_DIR/Dracula-icons.zip" \
        "https://github.com/dracula/gtk/files/5214870/Dracula.zip"
    step "Extracting Dracula icons..."
    mkdir -p "$ICON_DIR"
    unzip -q "$TEMP_DIR/Dracula-icons.zip" -d "$ICON_DIR"
    rm -rf "$TEMP_DIR"
    step "Updating icon cache..."
    gtk-update-icon-cache -f -t "$ICON_DIR/Dracula" 2>/dev/null || true
    success "Dracula icons installed!"
fi

# Apply theme via gsettings (required for Wayland - settings.ini is ignored!)
step "Applying Dracula theme via gsettings (required for Wayland)..."
gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'
gsettings set org.gnome.desktop.interface icon-theme 'Dracula'
gsettings set org.gnome.desktop.interface cursor-theme 'Dracula-cursors'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
success "gsettings configured!"

# Also set cursor size
gsettings set org.gnome.desktop.interface cursor-size 24

success "Dracula GTK theme & icons activated!"

# ----------------------------------------------------------------------------
# 5. Install Nerd Fonts
# ----------------------------------------------------------------------------

header "5/16 - Installing Nerd Fonts"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    warn "JetBrainsMono Nerd Font already installed, skipping..."
else
    step "Downloading JetBrainsMono Nerd Font..."
    TEMP_DIR=$(mktemp -d)
    curl -fsSL -o "$TEMP_DIR/JetBrainsMono.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    step "Extracting font..."
    mkdir -p "$FONT_DIR/JetBrainsMono"
    tar -xf "$TEMP_DIR/JetBrainsMono.tar.xz" -C "$FONT_DIR/JetBrainsMono"
    rm -rf "$TEMP_DIR"
    success "JetBrainsMono Nerd Font installed!"
fi

step "Refreshing font cache..."
fc-cache -fv >/dev/null 2>&1
success "Font cache refreshed!"

# ----------------------------------------------------------------------------
# 6. Setup ZSH
# ----------------------------------------------------------------------------

header "6/16 - Setting Up ZSH"

# Oh My Zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    warn "Oh My Zsh already installed, skipping..."
else
    step "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed!"
fi

# Powerlevel10k
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing "https://github.com/romkatv/powerlevel10k.git" \
    "$ZSH_CUSTOM/themes/powerlevel10k" "Powerlevel10k"

# ZSH Plugins
ZSH_PLUGINS=(
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
    "zsh-users/zsh-history-substring-search"
    "MichaelAquilina/zsh-you-should-use:you-should-use"
)

for plugin in "${ZSH_PLUGINS[@]}"; do
    repo="${plugin%%:*}"
    name="${plugin##*/}"; name="${name%%:*}"
    [[ "$plugin" == *:* ]] && name="${plugin##*:}"
    clone_if_missing "https://github.com/$repo.git" "$ZSH_CUSTOM/plugins/$name" "$name"
done

# Set ZSH as default shell
ZSH_PATH=$(which zsh)
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
    step "Setting ZSH as default shell..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    success "ZSH set as default shell!"
else
    warn "ZSH is already default shell"
fi

# ----------------------------------------------------------------------------
# 7. Stow Dotfiles
# ----------------------------------------------------------------------------

header "7/16 - Stowing Dotfiles"

# Stow config files
step "Stowing config files..."
cd "$SCRIPT_DIR/config"
for dir in */; do
    name="${dir%/}"
    step "  Stowing $name..."
    backup "$HOME/.config/$name"
    [[ "$name" == "hypr" ]] && backup "$HOME/.config/hypr/hyprland.conf"
    stow -t ~ "$name" || warn "  $name may have conflicts"
done
success "Config files stowed!"

# Stow home files
step "Stowing home files..."
cd "$SCRIPT_DIR/home"
for dir in */; do
    name="${dir%/}"
    step "  Stowing $name..."
    case "$name" in
        zsh)  backup "$HOME/.zshrc"; backup "$HOME/.p10k.zsh" ;;
        git)  backup "$HOME/.gitconfig" ;;
        tmux) backup "$HOME/.tmux.conf" ;;
    esac
    stow -t ~ "$name" || warn "  $name may have conflicts"
done
success "Home files stowed!"

# ----------------------------------------------------------------------------
# 8. Copy Scripts & Wallpapers
# ----------------------------------------------------------------------------

header "8/16 - Copying Scripts & Wallpapers"

step "Copying scripts to ~/.local/bin..."
mkdir -p ~/.local/bin
cp -r "$SCRIPT_DIR/bin/"* ~/.local/bin/
find ~/.local/bin -type f -name "*.sh" -exec chmod +x {} \;
chmod +x ~/.local/bin/* 2>/dev/null || true
success "Scripts copied!"

step "Copying wallpapers..."
mkdir -p ~/wallpapers
cp -r "$SCRIPT_DIR/wallpapers/"* ~/wallpapers/
success "Wallpapers copied!"

# ----------------------------------------------------------------------------
# 9. Setup TPM (Tmux Plugin Manager)
# ----------------------------------------------------------------------------

header "9/16 - Setting Up TPM"
clone_if_missing "https://github.com/tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm" "TPM"

# ----------------------------------------------------------------------------
# 10. Dracula Theme - VSCode
# ----------------------------------------------------------------------------

header "10/16 - Installing Dracula for VSCode"
if command -v code &>/dev/null; then
    step "Installing Dracula Official extension..."
    code --install-extension dracula-theme.theme-dracula --force 2>/dev/null || true

    # Set Dracula as default theme
    VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
    mkdir -p "$(dirname "$VSCODE_SETTINGS")"
    if [[ -f "$VSCODE_SETTINGS" ]]; then
        if ! grep -q "workbench.colorTheme" "$VSCODE_SETTINGS"; then
            # Add theme to existing settings
            sed -i '1a\  "workbench.colorTheme": "Dracula",' "$VSCODE_SETTINGS"
        fi
    else
        echo '{ "workbench.colorTheme": "Dracula" }' > "$VSCODE_SETTINGS"
    fi
    success "Dracula theme installed and set for VSCode!"
else
    warn "VSCode not installed, skipping..."
fi

# ----------------------------------------------------------------------------
# 12. Dracula Theme - Telegram
# ----------------------------------------------------------------------------

header "12/16 - Installing Dracula for Telegram"
TELEGRAM_DRACULA="$HOME/.local/share/dracula-telegram"
TELEGRAM_THEMES="$HOME/.local/share/TelegramDesktop/tdata"

if [[ -d "$TELEGRAM_DRACULA" ]]; then
    warn "Dracula for Telegram already downloaded, skipping..."
else
    step "Downloading Dracula theme for Telegram..."
    git clone --depth 1 https://github.com/dracula/telegram.git "$TELEGRAM_DRACULA"
    success "Dracula theme files downloaded!"
fi

# Try to find Telegram themes directory and copy theme
if [[ -d "$TELEGRAM_THEMES" ]]; then
    step "Copying theme to Telegram..."
    cp "$TELEGRAM_DRACULA/colors.tdesktop-theme" "$TELEGRAM_THEMES/" 2>/dev/null || true
    success "Theme copied! Open Telegram: Settings → Chat Settings → Choose from file"
else
    warn "Telegram data folder not found. To apply theme manually:"
    warn "  1. Open Telegram → Settings → Chat Settings"
    warn "  2. Click '...' → Create new theme → Import existing theme"
    warn "  3. Select: $TELEGRAM_DRACULA/colors.tdesktop-theme"
fi

# ----------------------------------------------------------------------------
# 13. Dracula Theme - LibreOffice
# ----------------------------------------------------------------------------

header "13/16 - Installing Dracula for LibreOffice"
LIBREOFFICE_DRACULA="$HOME/.local/share/dracula-libreoffice"

if [[ -d "$LIBREOFFICE_DRACULA" ]]; then
    warn "Dracula for LibreOffice already downloaded, skipping..."
else
    step "Downloading Dracula theme for LibreOffice..."
    git clone --depth 1 https://github.com/dracula/libreoffice.git "$LIBREOFFICE_DRACULA"
fi

# Try multiple LibreOffice config paths
LIBREOFFICE_INSTALLED=false
for version in 4 24.2 24.8 7 ; do
    LIBREOFFICE_CONFIG="$HOME/.config/libreoffice/${version}/user/config"
    if [[ -d "$(dirname "$LIBREOFFICE_CONFIG")" ]]; then
        step "Installing Dracula palette for LibreOffice $version..."
        mkdir -p "$LIBREOFFICE_CONFIG"
        cp "$LIBREOFFICE_DRACULA/dracula.soc" "$LIBREOFFICE_CONFIG/"
        LIBREOFFICE_INSTALLED=true
    fi
done

if [[ "$LIBREOFFICE_INSTALLED" = true ]]; then
    success "Dracula palette installed for LibreOffice!"
    warn "Select Dracula palette: Tools → Options → LibreOffice → Colors"
else
    warn "LibreOffice config not found. Run LibreOffice once, then re-run installer"
fi

# ----------------------------------------------------------------------------
# 14. Dracula Theme - fzf, TTY, zsh-syntax-highlighting
# ----------------------------------------------------------------------------

header "14/16 - Configuring Dracula for Shell Tools"

# Download all Dracula shell themes
TTY_DRACULA="$HOME/.local/share/dracula-tty"
ZSH_SYNTAX_DRACULA="$HOME/.local/share/dracula-zsh-syntax-highlighting"

clone_if_missing "https://github.com/dracula/tty.git" "$TTY_DRACULA" "Dracula TTY"
clone_if_missing "https://github.com/dracula/zsh-syntax-highlighting.git" "$ZSH_SYNTAX_DRACULA" "Dracula zsh-syntax-highlighting"

# Add all shell configurations to .zshrc
if ! grep -q "# Dracula Theme Configuration" "$HOME/.zshrc" 2>/dev/null; then
    step "Adding Dracula shell configurations to .zshrc..."
    cat >> "$HOME/.zshrc" << 'DRACULAEOF'

# ============================================================================
# Dracula Theme Configuration
# ============================================================================

# Dracula theme for fzf
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Dracula TTY colors (for Linux console)
if [ "$TERM" = "linux" ]; then
    printf %b '\e[40m' '\e[8]'
    printf %b '\e[37m' '\e[8]'
    printf %b '\e]P0282a36'
    printf %b '\e]P86272a4'
    printf %b '\e]P1ff5555'
    printf %b '\e]P9ff7777'
    printf %b '\e]P250fa7b'
    printf %b '\e]PA70fa9b'
    printf %b '\e]P3f1fa8c'
    printf %b '\e]PBffb86c'
    printf %b '\e]P4bd93f9'
    printf %b '\e]PCcfa9ff'
    printf %b '\e]P5ff79c6'
    printf %b '\e]PDff88e8'
    printf %b '\e]P68be9fd'
    printf %b '\e]PE97e2ff'
    printf %b '\e]P7f8f8f2'
    printf %b '\e]PFffffff'
    clear
fi

# Dracula zsh-syntax-highlighting colors
# Must be set BEFORE sourcing zsh-syntax-highlighting
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6272A4'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[function]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[command]='fg=#50FA7B'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#50FA7B,italic'
ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#FFB86C,italic'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFB86C'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFB86C'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#BD93F9'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#8BE9FD'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter-unquoted]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[assign]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF5555'
ZSH_HIGHLIGHT_STYLES[path]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=#FF79C6'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#BD93F9'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[rc-quote]='fg=#F1FA8C'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#F8F8F2'
ZSH_HIGHLIGHT_STYLES[default]='fg=#F8F8F2'
DRACULAEOF
    success "Dracula shell configurations added to .zshrc!"
else
    warn "Dracula shell configuration already in .zshrc, skipping..."
fi

# ----------------------------------------------------------------------------
# 15. Browser Extensions Info
# ----------------------------------------------------------------------------

header "15/16 - Browser Extensions (Manual Installation Required)"

echo -e "${CYAN}The following browser extensions need manual installation:${NC}"
echo ""
echo -e "  ${YELLOW}ChatGPT${NC}:  https://draculatheme.com/chatgpt"
echo -e "  ${YELLOW}Gemini${NC}:   https://draculatheme.com/gemini"
echo -e "  ${YELLOW}GitHub${NC}:   https://draculatheme.com/github"
echo -e "  ${YELLOW}GitLab${NC}:   https://draculatheme.com/gitlab"
echo -e "  ${YELLOW}LeetCode${NC}: https://draculatheme.com/leetcode"
echo ""
echo -e "${CYAN}All are available in Chrome Web Store and Firefox Add-ons.${NC}"

# Save to file for reference
cat > "$HOME/.config/dracula-browser-extensions.md" << 'EOF'
# Dracula Browser Extensions

Install these extensions manually from browser extension stores:

| Service  | Installation Link                      |
|----------|----------------------------------------|
| ChatGPT  | https://draculatheme.com/chatgpt       |
| Gemini   | https://draculatheme.com/gemini        |
| GitHub   | https://draculatheme.com/github        |
| GitLab   | https://draculatheme.com/gitlab        |
| LeetCode | https://draculatheme.com/leetcode      |

## Quick Install Links

- **Firefox Add-ons**: Search "Dracula" + service name
- **Chrome Web Store**: Search "Dracula" + service name

These extensions inject CSS into the respective websites to apply the Dracula theme.
EOF

success "Browser extensions info saved to ~/.config/dracula-browser-extensions.md"

# ----------------------------------------------------------------------------
# 16. Extra Dracula Themes (Manual Installation Required)
# ----------------------------------------------------------------------------

header "16/16 - Extra Dracula Themes (Manual Installation Required)"

echo -e "${CYAN}Manual Dracula themes available (not auto-installed by this script):${NC}"
echo ""
echo -e "  ${YELLOW}Firefox${NC}:      https://draculatheme.com/firefox"
echo -e "  ${YELLOW}Cursor${NC}:       https://draculatheme.com/cursor"
echo -e "  ${YELLOW}Tmux${NC}:         https://draculatheme.com/tmux"
echo -e "  ${YELLOW}Kitty${NC}:        https://draculatheme.com/kitty"
echo -e "  ${YELLOW}Git${NC}:          https://draculatheme.com/git"
echo -e "  ${YELLOW}Yazi${NC}:         https://draculatheme.com/yazi"
echo -e "  ${YELLOW}Obsidian${NC}:    https://draculatheme.com/obsidian"
echo -e "  ${YELLOW}Dunst${NC}:        https://draculatheme.com/dunst"
echo -e "  ${YELLOW}Monkeytype${NC}:   https://draculatheme.com/monkeytype"
echo -e "  ${YELLOW}gh-pages${NC}:     https://draculatheme.com/gh-pages"
echo -e "  ${YELLOW}YouTube${NC}:      https://draculatheme.com/youtube"
echo -e "  ${YELLOW}Stack Overflow${NC}: https://draculatheme.com/stackoverflow"
echo -e "  ${YELLOW}Libreddit${NC}:    https://draculatheme.com/libreddit"
echo ""
echo -e "${YELLOW}Note:${NC} Apply these manually if you want Dracula styling for the listed tools/services."

cat > "$HOME/.config/dracula-extra-themes.md" << 'EOF'
# Extra Dracula Themes (Manual)

The following official Dracula themes are available but not installed automatically:

| Tool / Service | Link                                   |
|----------------|----------------------------------------|
| Firefox        | https://draculatheme.com/firefox       |
| Cursor         | https://draculatheme.com/cursor        |
| Tmux           | https://draculatheme.com/tmux          |
| Kitty          | https://draculatheme.com/kitty         |
| Git            | https://draculatheme.com/git           |
| Yazi           | https://draculatheme.com/yazi          |
| Obsidian       | https://draculatheme.com/obsidian      |
| Dunst          | https://draculatheme.com/dunst         |
| Monkeytype     | https://draculatheme.com/monkeytype    |
| gh-pages       | https://draculatheme.com/gh-pages      |
| YouTube        | https://draculatheme.com/youtube       |
| Stack Overflow | https://draculatheme.com/stackoverflow |
| Libreddit      | https://draculatheme.com/libreddit     |
EOF

success "Extra Dracula theme links saved to ~/.config/dracula-extra-themes.md"

# ----------------------------------------------------------------------------
# Complete!
# ----------------------------------------------------------------------------

header "Installation Complete!"

echo -e "${GREEN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                  INSTALLATION COMPLETE!                   ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${CYAN}Next steps:${NC}"
echo -e "  ${YELLOW}1.${NC} Log out and log back in (or reboot)"
echo -e "  ${YELLOW}2.${NC} Start Hyprland: ${GREEN}Hyprland${NC}"
echo -e "  ${YELLOW}3.${NC} Install tmux plugins: ${GREEN}Ctrl+a${NC} then ${GREEN}I${NC}"
echo -e "  ${YELLOW}4.${NC} Configure prompt: ${GREEN}p10k configure${NC}"
echo ""
echo -e "${PURPLE}Keybindings:${NC}"
echo -e "  ${YELLOW}Super + Return${NC}  - Terminal"
echo -e "  ${YELLOW}Super + D${NC}       - App launcher"
echo -e "  ${YELLOW}Super + Q${NC}       - Power menu"
echo -e "  ${YELLOW}Super + W${NC}       - Close window"
echo -e "  ${YELLOW}Super + 1-7${NC}     - Workspaces"
echo ""
echo -e "${GREEN}Enjoy your new rice!${NC}"
