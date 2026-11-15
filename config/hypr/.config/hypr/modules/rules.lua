local floating = {
    class = { "pavucontrol", "nm-connection-editor", "blueman-manager", "yad" },
    title = { "Open File", "Save File", "Picture-in-Picture" },
}

for field, names in pairs(floating) do
    for _, name in ipairs(names) do
        hl.window_rule({ match = { [field] = "^(" .. name .. ")$" }, float = true })
    end
end

hl.window_rule({ match = { class = "^(kitty)$" }, opacity = "0.96 0.96" })

hl.window_rule({
    match = { class = "^(waypaper)$" },
    float = true,
    size = { 900, 600 },
    center = true,
})

hl.window_rule({
    match = { class = "^(wofi)$" },
    float = true,
    animation = "fade",
    pin = true,
    stay_focused = true,
    border_size = 0,
})

hl.layer_rule({ match = { namespace = "waybar" }, no_anim = true })
