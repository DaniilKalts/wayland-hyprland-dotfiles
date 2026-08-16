local floatingClasses = {
    "^(pavucontrol)$",
    "^(nm-connection-editor)$",
    "^(blueman-manager)$",
    "^(yad)$",
}

for _, class in ipairs(floatingClasses) do
    hl.window_rule({
        match = {
            class = class,
        },
        float = true,
    })
end

local floatingTitles = {
    "^(Open File)$",
    "^(Save File)$",
    "^(Picture-in-Picture)$",
}

for _, title in ipairs(floatingTitles) do
    hl.window_rule({
        match = {
            title = title,
        },
        float = true,
    })
end

hl.window_rule({
    match = {
        class = "^(kitty)$",
    },
    opacity = "0.96 0.96",
})

hl.window_rule({
    match = {
        class = "^(waypaper)$",
    },
    float = true,
    size = {
        900,
        600,
    },
    center = true,
})

hl.window_rule({
    match = {
        class = "^(wofi)$",
    },
    float = true,
    animation = "fade",
    pin = true,
    stay_focused = true,
    border_size = 0,
})

hl.layer_rule({
    match = {
        namespace = "waybar",
    },
    no_anim = true,
})
