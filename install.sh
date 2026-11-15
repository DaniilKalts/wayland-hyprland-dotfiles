#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m'
BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' NC='\033[0m'

STEP=0
TOTAL="$(grep -c '^header "' "${BASH_SOURCE[0]}")"

header() {
    STEP=$((STEP + 1))
    echo -e "\n${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ${STEP}/${TOTAL} - $1${NC}"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════════${NC}\n"
}

step()    { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
err()     { echo -e "${RED}[✗]${NC} $1"; }
die()     { err "$1"; exit 1; }

backup() {
    local target="$1"
    if [[ -L "$target" ]]; then
        rm -f "$target"
    elif [[ -e "$target" ]]; then
        warn "Backing up $target"
        mv "$target" "$target.bak.$(date +%s)"
    fi
}

clone_if_missing() {
    local url="$1" dest="$2" name="$3"
    if [[ -d "$dest" ]]; then
        warn "$name already installed, skipping..."
        return 0
    fi
    step "Installing $name..."
    git clone --depth 1 "$url" "$dest"
    success "$name installed!"
}

copy_dir_contents() {
    local src="$1" dst="$2" what="$3"
    if [[ ! -d "$src" || -z "$(ls -A "$src")" ]]; then
        warn "$what folder missing or empty: $src (skipping)"
        return 0
    fi
    mkdir -p "$dst"
    cp -r "$src/." "$dst/"
}

[[ "${EUID:-$(id -u)}" -eq 0 ]] && die "Do not run as root!"
[[ -f /etc/arch-release ]] || die "This installer only supports Arch Linux."
command -v sudo &>/dev/null || die "sudo is required."

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
read -rp "Press Enter to continue or Ctrl+C to cancel..."

# Ask for the sudo password once and keep it alive for the whole run
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!
trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

header "Updating System"

# multilib is needed for wine and 32-bit drivers
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    step "Enabling multilib repository..."
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi

sudo pacman -Syu --needed --noconfirm base-devel git
success "System updated!"

header "Installing Yay (AUR Helper)"
if command -v yay &>/dev/null; then
    warn "Yay already installed, skipping..."
else
    YAY_TMP="$(mktemp -d)"
    git clone https://aur.archlinux.org/yay-bin.git "$YAY_TMP"
    (cd "$YAY_TMP" && makepkg -si --noconfirm)
    rm -rf "$YAY_TMP"
    success "Yay installed!"
fi

header "Installing Pacman Packages"

# Packages are grouped by the same categories in the pacman, AUR and snap lists

PACMAN_PACKAGES=(
    # Desktop: Hyprland & Wayland
    hyprland hyprlock hypridle hyprpicker
    waybar dunst swaybg wofi wl-clipboard wl-clip-persist cliphist libnotify
    polkit-gnome xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
    xdg-user-dirs xdg-utils qt5-wayland qt6-wayland qt6ct

    # Drivers: AMD iGPU + NVIDIA dGPU
    mesa vulkan-radeon lib32-vulkan-radeon
    nvidia-open-dkms nvidia-utils lib32-nvidia-utils linux-headers

    # Audio
    pipewire pipewire-pulse pipewire-alsa wireplumber
    pavucontrol playerctl alsa-utils

    # Network & Bluetooth
    networkmanager bluez bluez-utils blueman bluetui nmap nload

    # Terminal & Shell
    kitty zsh tmux stow

    # Editors
    neovim vim nano

    # CLI Tools
    ripgrep fd fzf bat eza zoxide jq trash-cli psmisc
    tldr rsync tree unzip zip 7zip wget curl
    chafa glow tokei go-task

    # Git
    git-delta github-cli git-filter-repo tig

    # Development: languages & build tools (also used by Neovim Mason)
    nodejs npm pnpm python python-pip go rustup jdk-openjdk
    tree-sitter-cli cmake opencode shellcheck stylua

    # Containers
    docker docker-compose docker-buildx lazydocker dive kubectl

    # Databases
    postgresql dbeaver

    # Virtualization
    qemu-full libvirt virt-manager edk2-ovmf swtpm dnsmasq wine winetricks

    # System Monitoring & Hardware
    btop htop fastfetch inxi ncdu dust lsof acpi brightnessctl gparted openrgb

    # Pacman Maintenance
    reflector pacman-contrib flatpak

    # File Management
    thunar gvfs tumbler yazi ffmpegthumbnailer poppler resvg

    # Screenshots & Images
    grim slurp satty imagemagick silicon flameshot gpick viewnior feh

    # Media
    obs-studio vlc cava

    # Browsers & Internet
    firefox-developer-edition torbrowser-launcher tor qbittorrent

    # Apps
    telegram-desktop obsidian libreoffice-still zathura zathura-pdf-mupdf

    # Fun
    cmatrix cowsay figlet lolcat toilet sl

    # Fonts & Icons
    ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono noto-fonts noto-fonts-emoji
    otf-font-awesome papirus-icon-theme
)

step "Installing ${#PACMAN_PACKAGES[@]} packages..."
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
success "Pacman packages installed!"

# rustup installs no toolchain by default; cargo is needed by zshrc and Mason
if ! rustup toolchain list 2>/dev/null | grep -q stable; then
    step "Installing stable Rust toolchain..."
    rustup default stable
fi

header "Installing AUR Packages"

AUR_PACKAGES=(
    # Desktop: Hyprland & Wayland
    espanso-wayland waypaper

    # Editors
    cursor-bin visual-studio-code-bin antigravity

    # Development: API clients
    postman-bin insomnia

    # System Monitoring & Hardware
    ps_mem

    # Pacman Maintenance
    snapd debtap

    # Browsers & Internet
    google-chrome localsend-bin

    # Fun
    tty-clock neofetch

    # Theme
    dracula-gtk-theme dracula-cursors-git
)

SNAP_PACKAGES=(
    # Editors
    goland

    # Git
    gitkraken

    # Databases
    pgadmin4
)

step "Installing ${#AUR_PACKAGES[@]} AUR packages..."
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
success "AUR packages installed!"

header "Setting Up Flatpak & Snap"

step "Adding Flathub remote..."
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
success "Flatpak ready!"

step "Enabling snapd..."
sudo systemctl enable --now snapd.socket
# Classic snaps expect /snap
[[ -e /snap ]] || sudo ln -s /var/lib/snapd/snap /snap
success "Snap ready!"

step "Installing snap apps..."
sudo snap wait system seed.loaded
for app in "${SNAP_PACKAGES[@]}"; do
    sudo snap install "$app" --classic 2>/dev/null || sudo snap install "$app" \
        || warn "Failed to install $app (snap)"
done
success "Snap apps installed!"

header "Enabling System Services"

sudo systemctl enable --now NetworkManager.service bluetooth.service docker.service libvirtd.service

# Weekly: refresh to the fastest mirrors, and trim the package cache
sudo systemctl enable reflector.timer paccache.timer

# PostgreSQL needs its data directory initialized once
if [[ -z "$(sudo ls -A /var/lib/postgres/data 2>/dev/null)" ]]; then
    step "Initializing PostgreSQL..."
    sudo -iu postgres initdb -D /var/lib/postgres/data
fi
sudo systemctl enable --now postgresql.service

# Use docker and VMs without sudo
sudo usermod -aG docker,libvirt "$USER"
success "Services enabled: NetworkManager, bluetooth, docker, libvirtd, postgresql"

header "Creating Home Directories"

HOME_DIRS=(documents downloads pictures programs projects recordings)
for dir in "${HOME_DIRS[@]}"; do
    mkdir -p "$HOME/$dir"
done
mkdir -p "$HOME/pictures/screenshots" "$HOME/pictures/wallpapers"
success "Home directories created: ${HOME_DIRS[*]}"

header "Setting Up ZSH"

if [[ -d "$HOME/.oh-my-zsh" ]]; then
    warn "Oh My Zsh already installed, skipping..."
else
    step "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed!"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing "https://github.com/romkatv/powerlevel10k.git" \
    "$ZSH_CUSTOM/themes/powerlevel10k" "Powerlevel10k"

ZSH_PLUGINS=(
    "zsh-users/zsh-syntax-highlighting"
    "zsh-users/zsh-autosuggestions"
    "zsh-users/zsh-completions"
    "zsh-users/zsh-history-substring-search"
    "MichaelAquilina/zsh-you-should-use:you-should-use"
)

for plugin in "${ZSH_PLUGINS[@]}"; do
    repo="${plugin%%:*}"
    name="${repo##*/}"
    [[ "$plugin" == *:* ]] && name="${plugin##*:}"
    clone_if_missing "https://github.com/$repo.git" "$ZSH_CUSTOM/plugins/$name" "$name"
done

ZSH_PATH="$(command -v zsh)"
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
    step "Setting ZSH as default shell..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    success "ZSH set as default shell!"
else
    warn "ZSH is already default shell"
fi

header "Stowing Dotfiles"

# Back up real files in the way, but never ones that already resolve into this repo.
stow_package() {
    local base="$1" name="$2" target="$3" file
    step "  Stowing $name..."
    mkdir -p "$target"
    while IFS= read -r file; do
        file="$target/$file"
        [[ -e "$file" && ! -L "$file" ]] || continue
        [[ "$(realpath "$file")" == "$SCRIPT_DIR"/* ]] || backup "$file"
    done < <(cd "$base/$name" && find . -type f -printf '%P\n')
    stow --restow -t "$target" -d "$base" "$name" || warn "  $name may have conflicts"
}

for group in config home; do
    for package in "$SCRIPT_DIR/$group"/*/; do
        stow_package "$SCRIPT_DIR/$group" "$(basename "$package")" "$HOME"
    done
done
stow_package "$SCRIPT_DIR" bin "$HOME/.local/bin"
success "Dotfiles and scripts stowed!"

header "Copying Wallpapers"

copy_dir_contents "$SCRIPT_DIR/wallpapers" "$HOME/pictures/wallpapers" "Wallpapers"
success "Wallpapers copied to ~/pictures/wallpapers!"

header "Setting Up Neovim"

clone_if_missing "https://github.com/folke/lazy.nvim.git" \
    "$HOME/.local/share/nvim/lazy/lazy.nvim" "lazy.nvim"

step "Syncing Neovim plugins..."
nvim --headless "+Lazy! sync" +qa || warn "Plugin sync failed. Open Neovim to finish installation."
success "Neovim ready!"

header "Installing AI Tools"

# Global npm packages go to ~/.npm-global (already on PATH in .zshrc)
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"

NPM_PACKAGES=(
    @openai/codex
    @google/gemini-cli
)

step "Installing ${NPM_PACKAGES[*]}..."
npm install -g "${NPM_PACKAGES[@]}" || warn "Some npm packages failed to install"

if command -v claude &>/dev/null; then
    warn "Claude Code already installed, skipping..."
else
    step "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code install failed"
fi
success "AI tools installed: Claude Code, Codex, Gemini CLI"

header "Setting Up Tmux"
clone_if_missing "https://github.com/tmux-plugins/tpm.git" "$HOME/.tmux/plugins/tpm" "TPM"
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null 2>&1 \
    || warn "Install tmux plugins manually: Ctrl+a then I"

header "Setting Up Espanso"

# espanso reads keyboard input from /dev/input
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx input; then
    step "Adding $USER to the input group..."
    sudo usermod -aG input "$USER"
fi

step "Setting capabilities on espanso..."
sudo setcap cap_dac_override+p "$(readlink -f "$(command -v espanso)")"

step "Registering espanso service..."
espanso service register || warn "espanso service already registered"
success "Espanso ready! It starts with your next session."

header "Applying Dracula Theme"

ICON_DIR="$HOME/.icons"
if [[ -d "$ICON_DIR/Dracula" ]]; then
    warn "Dracula icons already installed, skipping..."
else
    step "Downloading Dracula icon theme..."
    TEMP_DIR="$(mktemp -d)"
    curl -fsSL -o "$TEMP_DIR/Dracula-icons.zip" \
        "https://github.com/dracula/gtk/files/5214870/Dracula.zip"
    mkdir -p "$ICON_DIR"
    unzip -q "$TEMP_DIR/Dracula-icons.zip" -d "$ICON_DIR"
    rm -rf "$TEMP_DIR"
    gtk-update-icon-cache -f -t "$ICON_DIR/Dracula" 2>/dev/null || true
    success "Dracula icons installed!"
fi

# gsettings needs a D-Bus session; Hyprland autostart applies these anyway
step "Applying GTK settings..."
{
    gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'
    gsettings set org.gnome.desktop.interface icon-theme 'Dracula'
    gsettings set org.gnome.desktop.interface cursor-theme 'Dracula-cursors'
    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
} 2>/dev/null && success "GTK settings applied!" \
    || warn "No D-Bus session; Hyprland will apply GTK settings on first start."

fc-cache -f >/dev/null 2>&1
success "Font cache refreshed!"

header "Installing Dracula for Apps"

# VSCode
if command -v code &>/dev/null; then
    step "Installing Dracula for VSCode..."
    code --install-extension dracula-theme.theme-dracula --force >/dev/null 2>&1 || true
    VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
    mkdir -p "$(dirname "$VSCODE_SETTINGS")"
    if [[ ! -f "$VSCODE_SETTINGS" ]]; then
        echo '{ "workbench.colorTheme": "Dracula Theme" }' > "$VSCODE_SETTINGS"
    elif ! grep -q "workbench.colorTheme" "$VSCODE_SETTINGS"; then
        sed -i '1a\  "workbench.colorTheme": "Dracula Theme",' "$VSCODE_SETTINGS"
    fi
    success "Dracula set for VSCode!"
fi

# Telegram
TELEGRAM_DRACULA="$HOME/.local/share/dracula-telegram"
clone_if_missing "https://github.com/dracula/telegram.git" "$TELEGRAM_DRACULA" "Dracula for Telegram"
warn "Telegram: Settings → Chat Settings → '...' → Import theme → $TELEGRAM_DRACULA/colors.tdesktop-theme"

# LibreOffice (only if installed and run once)
LIBREOFFICE_DRACULA="$HOME/.local/share/dracula-libreoffice"
if [[ -d "$HOME/.config/libreoffice" ]]; then
    clone_if_missing "https://github.com/dracula/libreoffice.git" "$LIBREOFFICE_DRACULA" "Dracula for LibreOffice"
    for config in "$HOME"/.config/libreoffice/*/user/config; do
        [[ -d "$config" ]] && cp "$LIBREOFFICE_DRACULA/dracula.soc" "$config/"
    done
    success "Dracula palette installed for LibreOffice!"
fi

header "Saving Manual Theme Links"

cat > "$HOME/.config/dracula-manual-themes.md" << 'EOF'
# Dracula Themes (Manual Installation)

Browser extensions (Chrome Web Store / Firefox Add-ons):

| Service        | Link                                   |
|----------------|----------------------------------------|
| ChatGPT        | https://draculatheme.com/chatgpt       |
| Gemini         | https://draculatheme.com/gemini        |
| GitHub         | https://draculatheme.com/github        |
| GitLab         | https://draculatheme.com/gitlab        |
| LeetCode       | https://draculatheme.com/leetcode      |
| YouTube        | https://draculatheme.com/youtube       |
| Stack Overflow | https://draculatheme.com/stackoverflow |
| Monkeytype     | https://draculatheme.com/monkeytype    |

Apps:

| App      | Link                              |
|----------|-----------------------------------|
| Firefox  | https://draculatheme.com/firefox  |
| Cursor   | https://draculatheme.com/cursor   |
| Obsidian | https://draculatheme.com/obsidian |
EOF
success "Saved to ~/.config/dracula-manual-themes.md"

echo -e "${GREEN}"
cat << "EOF"
    ╔═══════════════════════════════════════════════════════════╗
    ║                  INSTALLATION COMPLETE!                   ║
    ╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${CYAN}Next steps:${NC}"
echo -e "  ${YELLOW}1.${NC} Reboot (needed for the input group, snap and the default shell)"
echo -e "  ${YELLOW}2.${NC} Start Hyprland: ${GREEN}Hyprland${NC}"
echo -e "  ${YELLOW}3.${NC} Configure prompt: ${GREEN}p10k configure${NC}"
echo -e "  ${YELLOW}4.${NC} Keybindings are listed in ${GREEN}README.md${NC}"
echo ""
echo -e "${GREEN}Enjoy your new rice!${NC}"
