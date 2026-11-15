<h1 align="left">📘 About</h1>

</br>

- **OS**: [**`Arch Linux`**](https://archlinux.org/)
- **WM**: [**`Hyprland`**](https://wiki.hypr.land/)
- **Bar**: [**`Waybar`**](https://waybar.org/)
- **Terminal**: [**`Kitty`**](https://github.com/kovidgoyal/kitty)
- **App Launcher**: [**`Wofi`**](https://github.com/SimplyCEO/wofi)
- **Notify Daemon**: [**`Dunst`**](https://github.com/dunst-project/dunst)
- **Shell**: [**`Zsh`**](https://github.com/ohmyzsh/ohmyzsh)
- **Text Editor**: [**`Neovim`**](https://neovim.io/)
- **File Manager**: [**`Thunar`**](https://github.com/xfce/thunar)
- **Browser**: [**`Firefox Developer Edition`**](https://www.mozilla.org/en-US/firefox/developer/)
- **Screenshot Editor**: [**`Satty`**](https://github.com/Satty-org/Satty)
- **Wallpaper Selector**: [**`Waypaper`**](https://anufrievroman.gitbook.io/waypaper)
- **Terminal Multiplexer**: [**`Tmux`**](https://github.com/tmux/tmux)
- **Terminal File Manager**: [**`Yazi`**](https://yazi-rs.github.io/)
- **Symlink Manager**: [**`Stow`**](https://www.gnu.org/software/stow/manual/stow.html)
- **Font Family**: [**`JetBrainsMono Nerd Font`**](https://www.jetbrains.com/lp/mono/)
- **Theme**: [**`Dracula`**](https://draculatheme.com/)

</br>

## 🖼️ Gallery

### Dracula Github
![Dracula Github](./demonstrations/arch-rice-dracula-github.png)

### Preview
![Preview](./demonstrations/arch-rice-preview.png)

### Wallpaper Selector
![Wallpaper Selector](./demonstrations/arch-rice-wallpaper-selector.png)

### System Monitor
![System Monitor](./demonstrations/arch-rice-system-monitor.png)

### Program Launcher
![Program Launcher](./demonstrations/arch-rice-program-launcher.png)

### Ai Menu
![Ai Menu](./demonstrations/arch-rice-ai-menu.png)

### Dracula Chatgpt
![Dracula Chatgpt](./demonstrations/arch-rice-dracula-chatgpt.png)

### Dracula Gemini
![Dracula Gemini](./demonstrations/arch-rice-dracula-gemini.png)

### Gemini Cli
![Gemini Cli](./demonstrations/arch-rice-gemini-cli.png)

### Claude Cli
![Claude Cli](./demonstrations/arch-rice-claude-cli.png)

### Neovim
![Neovim](./demonstrations/arch-rice-neovim.png)

### File Listing
![File Listing](./demonstrations/arch-rice-file-listing.png)

### Screenshot Edit
![Screenshot Edit](./demonstrations/arch-rice-screenshot-edit.png)

### Select Color
![Select Color](./demonstrations/arch-rice-select-color.png)

### Power Menu
![Power Menu](./demonstrations/arch-rice-power-menu.png)

## 💻 HotKeys

- **Open the terminal** - `super + enter`
- **Close the focused window** - `super + w`
- **Switch to a workspace** - `super + 1-9`
- **Move the window to a workspace** - `super + shift + 1-9`
- **Focus a neighbouring window** - `super + h/j/k/l`
- **Float / tile / fullscreen the window** - `super + s` / `super + n` / `super + f`
- **Application menu** - `super + d`
- **Power menu** - `super + q`
- **AI menu** - `super + c`
- **IDE menu** - `super + i`
- **Clipboard history** - `super + shift + c`
- **Wallpaper selector** - `super + shift + s`
- **Screenshot the screen to a file** - `super + p`
- **Screenshot a region and annotate it** - `super + shift + p`
- **Screenshot the screen / a region to the clipboard** - `super + ctrl + p` / `super + ctrl + shift + p`
- **Lock the screen** - `super + escape`
- **Log out** - `super + alt + q`
- **Pick a color to the clipboard** - `alt + p`
- **Open Yazi in a new terminal tab** - `ctrl + y`

All bindings live in `config/hypr/.config/hypr/modules/bindings.lua`.

## 🛠️ Installation

Run the installer from the root of the repository. It links the configs and `bin/` scripts into place with Stow, so edits in the repository apply immediately.

```
./install.sh
```
