local shared = require("modules.shared")
local mod = shared.mod

hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + W", hl.dsp.window.kill())

hl.bind(mod .. " + N", function()
    local window = hl.get_active_window()
    if window == nil then
        return
    end

    if window.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({
            action = "unset",
        }))
    end
    if window.floating then
        hl.dispatch(hl.dsp.window.float({
            action = "unset",
        }))
    end
end)

hl.bind(mod .. " + SHIFT + T", hl.dsp.window.pseudo())

hl.bind(mod .. " + S", function()
    local window = hl.get_active_window()
    if window == nil then
        return
    end

    if window.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({
            action = "unset",
        }))
    end
    if not window.floating then
        hl.dispatch(hl.dsp.window.float({
            action = "set",
        }))
        hl.dispatch(hl.dsp.window.resize({
            x = 1200,
            y = 800,
        }))
        hl.dispatch(hl.dsp.window.center())
    end
end)

hl.bind(mod .. " + F", function()
    local window = hl.get_active_window()
    if window ~= nil and window.fullscreen == 0 then
        hl.dispatch(hl.dsp.window.fullscreen({
            action = "set",
        }))
    end
end)

local focusDirections = {
    H = "left",
    J = "down",
    K = "up",
    L = "right",
}

for key, direction in pairs(focusDirections) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({
        direction = direction,
    }))
end

local moveDirections = {
    J = "down",
    K = "up",
    L = "right",
}

for key, direction in pairs(moveDirections) do
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({
        direction = direction,
    }))
end

local borderHighlighted = true
hl.bind(mod .. " + CTRL + H", function()
    borderHighlighted = not borderHighlighted
    hl.config({
        general = {
            col = {
                active_border = borderHighlighted
                    and shared.colors.active_border
                    or shared.colors.inactive_border,
            },
        },
    })
end)

hl.bind(mod .. " + SHIFT + H", hl.dsp.exec_cmd("~/.local/bin/toggle-window-visibility.sh"))
hl.bind(mod .. " + grave", hl.dsp.focus({
    last = true,
}))
hl.bind(mod .. " + Tab", hl.dsp.window.cycle_next({
    next = true,
}))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({
    prev = true,
}))

local resizeDeltas = {
    H = {
        -40,
        0,
    },
    J = {
        0,
        40,
    },
    K = {
        0,
        -40,
    },
    L = {
        40,
        0,
    },
}

for key, delta in pairs(resizeDeltas) do
    hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.resize({
        x = delta[1],
        y = delta[2],
        relative = true,
    }))
end

local moveDeltas = {
    Left = {
        -20,
        0,
    },
    Down = {
        0,
        20,
    },
    Up = {
        0,
        -20,
    },
    Right = {
        20,
        0,
    },
}

for key, delta in pairs(moveDeltas) do
    hl.bind(mod .. " + " .. key, hl.dsp.window.move({
        x = delta[1],
        y = delta[2],
        relative = true,
    }))
end

hl.bind(mod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true,
})
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true,
})

for workspace = 1, 9 do
    local key = tostring(workspace)
    hl.bind(mod .. " + " .. key, hl.dsp.focus({
        workspace = workspace,
    }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({
        workspace = workspace,
    }))
    hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({
        workspace = workspace,
        silent = true,
    }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({
    workspace = "e+1",
}))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({
    workspace = "e-1",
}))

local function execBind(keys, command, options)
    hl.bind(keys, hl.dsp.exec_cmd(command), options)
end

execBind(mod .. " + Return", "kitty --directory ~")
execBind(mod .. " + O", "kitty --directory ~")
execBind(mod .. " + Escape", "hyprlock")
hl.bind(mod .. " + ALT + Q", hl.dsp.exit())
execBind(mod .. " + M", "kitty --directory ~ btop")
execBind(mod .. " + E", "thunar ~")
execBind(mod .. " + D", "wofi --show drun")
execBind(mod .. " + Q", "~/.local/bin/powermenu.sh")
execBind(mod .. " + C", "~/.local/bin/aimenu.sh")
execBind(mod .. " + I", "~/.local/bin/idemenu.sh")
execBind(mod .. " + T", "kitty --directory ~ tmux")

execBind("ALT + F", "firefox-developer-edition")
execBind("ALT + G", "~/.local/bin/open-url.sh https://mail.google.com/mail/u/0/#inbox")
execBind("ALT + W", "~/.local/bin/open-url.sh https://web.whatsapp.com/")
execBind("ALT + T", "Telegram")
execBind("ALT + Y", "~/.local/bin/open-url.sh https://youtube.com/")
execBind(mod .. " + ALT + T", "teams")

execBind("ALT + O", "obsidian")
execBind("ALT + H", "~/.local/bin/open-url.sh https://github.com/")
execBind("ALT + I", "~/.local/bin/open-url.sh https://ticktick.com/signin")
execBind("ALT + R", "~/.local/bin/open-url.sh https://roadmap.sh/")
execBind("ALT + E", "~/.local/bin/open-url.sh https://chat.openai.com/")
execBind("ALT + X", "~/.local/bin/open-url.sh https://excalidraw.com/")
execBind("ALT + L", "~/.local/bin/open-url.sh https://leetcode.com/")
execBind("ALT + Q", "~/.local/bin/open-url.sh https://monkeytype.com/")
execBind("ALT + C", "cursor")
execBind("ALT + P", "~/.local/bin/color-picker.sh")

execBind(mod .. " + P", "~/.local/bin/screenshot.sh fullscreen-save")
execBind(mod .. " + SHIFT + P", "~/.local/bin/screenshot.sh region")
execBind(mod .. " + CTRL + P", "~/.local/bin/screenshot.sh fullscreen-copy")
execBind(mod .. " + CTRL + SHIFT + P", "~/.local/bin/screenshot.sh region-copy")
execBind(mod .. " + SHIFT + S", "waypaper")
execBind(mod .. " + V", "obs")
execBind(mod .. " + B", "killall -SIGUSR1 waybar")

local restartWaybar = table.concat(
    {
        "killall waybar",
        "sleep 0.5",
        "waybar -c ~/.config/waybar/config.jsonc -s ~/.config/waybar/style.css",
    },
    " && "
)

execBind(
    mod .. " + SHIFT + B",
    restartWaybar
)

execBind("ALT + M", "~/.local/bin/volume.sh toggle")
execBind(
    "ALT + K",
    "~/.local/bin/volume.sh up",
    {
        locked = true,
        repeating = true,
    }
)
execBind(
    "ALT + J",
    "~/.local/bin/volume.sh down",
    {
        locked = true,
        repeating = true,
    }
)
execBind(
    "XF86AudioRaiseVolume",
    "~/.local/bin/volume.sh up",
    {
        locked = true,
        repeating = true,
    }
)
execBind(
    "XF86AudioLowerVolume",
    "~/.local/bin/volume.sh down",
    {
        locked = true,
        repeating = true,
    }
)
execBind(
    "XF86AudioMute",
    "~/.local/bin/volume.sh toggle",
    {
        locked = true,
    }
)
execBind(
    "XF86AudioPlay",
    "playerctl play-pause",
    {
        locked = true,
    }
)
execBind(
    "XF86AudioPrev",
    "playerctl previous",
    {
        locked = true,
    }
)
execBind(
    "XF86AudioNext",
    "playerctl next",
    {
        locked = true,
    }
)

local repeatLocked = {
    locked = true,
    repeating = true,
}
execBind("XF86MonBrightnessUp", "brightnessctl set 5%+", repeatLocked)
execBind("XF86MonBrightnessDown", "brightnessctl set 5%-", repeatLocked)
execBind("F8", "brightnessctl set 5%+", repeatLocked)
execBind("F7", "brightnessctl set 5%-", repeatLocked)

execBind(mod .. " + SHIFT + C", "cliphist list | wofi --dmenu | cliphist decode | wl-copy")
