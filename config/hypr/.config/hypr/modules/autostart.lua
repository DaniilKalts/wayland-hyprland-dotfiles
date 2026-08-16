local commands = {
    "~/.local/bin/waybar-restart.sh",
    "dunst",
    "~/.local/bin/screenshot-watcher.sh",
    "hypridle",
    "swaybg -i ~/pictures/wallpapers/arch.png -m fill",
    "/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1",
    "wl-paste --type text --watch cliphist store",
    "wl-paste --type image --watch cliphist store",
    "gsettings set org.gnome.desktop.interface gtk-theme 'Dracula'",
    "gsettings set org.gnome.desktop.interface icon-theme 'Dracula'",
    "gsettings set org.gnome.desktop.interface cursor-theme 'Dracula-cursors'",
    "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'",
}

hl.on("hyprland.start", function()
    for _, command in ipairs(commands) do
        hl.exec_cmd(command)
    end
end)
