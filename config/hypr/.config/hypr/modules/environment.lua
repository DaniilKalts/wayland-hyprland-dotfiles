local variables = {
    XCURSOR_SIZE = "24",
    XCURSOR_THEME = "Dracula-cursors",
    GTK_THEME = "Dracula",
    QT_QPA_PLATFORMTHEME = "qt6ct",
    QT_QPA_PLATFORM = "wayland;xcb",
    GDK_BACKEND = "wayland,x11",
    SDL_VIDEODRIVER = "wayland",
    CLUTTER_BACKEND = "wayland",
    XDG_CURRENT_DESKTOP = "Hyprland",
    XDG_SESSION_TYPE = "wayland",
    XDG_SESSION_DESKTOP = "Hyprland",
    ELECTRON_OZONE_PLATFORM_HINT = "auto",
}

for name, value in pairs(variables) do
    hl.env(name, value)
end
