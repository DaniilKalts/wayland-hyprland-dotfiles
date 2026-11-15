local shared = require("modules.shared")
local mod = shared.mod
local bin = "~/.local/bin/"
local terminal = "kitty --directory ~"
local browse = bin .. "open-url.sh "

local function exec(keys, command, options)
    hl.bind(keys, hl.dsp.exec_cmd(command), options)
end

local function onActiveWindow(action)
    return function()
        local window = hl.get_active_window()
        if window ~= nil then
            action(window)
        end
    end
end

local function leaveFullscreen(window)
    if window.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ action = "unset" }))
    end
end

hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + W", hl.dsp.window.kill())
hl.bind(mod .. " + SHIFT + T", hl.dsp.window.pseudo())
hl.bind(mod .. " + R", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + grave", hl.dsp.focus({ last = true }))
hl.bind(mod .. " + Tab", hl.dsp.window.cycle_next({ next = true }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ prev = true }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + ALT + Q", hl.dsp.exit())

hl.bind(mod .. " + N", onActiveWindow(function(window)
    leaveFullscreen(window)
    if window.floating then
        hl.dispatch(hl.dsp.window.float({ action = "unset" }))
    end
end))

hl.bind(mod .. " + S", onActiveWindow(function(window)
    leaveFullscreen(window)
    if not window.floating then
        hl.dispatch(hl.dsp.window.float({ action = "set" }))
        hl.dispatch(hl.dsp.window.resize({ x = 1200, y = 800 }))
        hl.dispatch(hl.dsp.window.center())
    end
end))

hl.bind(mod .. " + F", onActiveWindow(function(window)
    if window.fullscreen == 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ action = "set" }))
    end
end))

local borderHighlighted = true
hl.bind(mod .. " + CTRL + H", function()
    borderHighlighted = not borderHighlighted
    local color = borderHighlighted and shared.colors.active_border or shared.colors.inactive_border
    hl.config({ general = { col = { active_border = color } } })
end)

for key, direction in pairs({ H = "left", J = "down", K = "up", L = "right" }) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
end

for key, direction in pairs({ J = "down", K = "up", L = "right" }) do
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

for key, delta in pairs({ H = { -40, 0 }, J = { 0, 40 }, K = { 0, -40 }, L = { 40, 0 } }) do
    hl.bind(mod .. " + ALT + " .. key, hl.dsp.window.resize({ x = delta[1], y = delta[2], relative = true }))
end

for key, delta in pairs({ Left = { -20, 0 }, Down = { 0, 20 }, Up = { 0, -20 }, Right = { 20, 0 } }) do
    hl.bind(mod .. " + " .. key, hl.dsp.window.move({ x = delta[1], y = delta[2], relative = true }))
end

for workspace = 1, 9 do
    hl.bind(mod .. " + " .. workspace, hl.dsp.focus({ workspace = workspace }))
    hl.bind(mod .. " + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace }))
    hl.bind(mod .. " + CTRL + " .. workspace, hl.dsp.window.move({ workspace = workspace, silent = true }))
end

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

exec(mod .. " + Return", terminal)
exec(mod .. " + O", terminal)
exec(mod .. " + T", terminal .. " tmux")
exec(mod .. " + M", terminal .. " btop")
exec(mod .. " + E", "thunar ~")
exec(mod .. " + D", "wofi --show drun")
exec(mod .. " + V", "obs")
exec(mod .. " + Escape", "hyprlock")
exec(mod .. " + Q", bin .. "powermenu.sh")
exec(mod .. " + C", bin .. "aimenu.sh")
exec(mod .. " + I", bin .. "idemenu.sh")
exec(mod .. " + SHIFT + H", bin .. "toggle-window-visibility.sh")
exec(mod .. " + SHIFT + S", "waypaper")
exec(mod .. " + SHIFT + C", "cliphist list | wofi --dmenu | cliphist decode | wl-copy")
exec(mod .. " + B", "killall -SIGUSR1 waybar")
exec(mod .. " + SHIFT + B", "killall -SIGUSR2 waybar")
exec(mod .. " + ALT + T", "teams")

exec("ALT + F", "firefox-developer-edition")
exec("ALT + T", "Telegram")
exec("ALT + O", "obsidian")
exec("ALT + C", terminal .. " claude")
exec("ALT + P", bin .. "color-picker.sh")
exec("ALT + G", browse .. "https://mail.google.com/mail/u/0/#inbox")
exec("ALT + W", browse .. "https://web.whatsapp.com/")
exec("ALT + Y", browse .. "https://youtube.com/")
exec("ALT + H", browse .. "https://github.com/")
exec("ALT + I", browse .. "https://ticktick.com/signin")
exec("ALT + R", browse .. "https://roadmap.sh/")
exec("ALT + E", browse .. "https://chat.openai.com/")
exec("ALT + X", browse .. "https://excalidraw.com/")
exec("ALT + L", browse .. "https://leetcode.com/")
exec("ALT + Q", browse .. "https://monkeytype.com/")

exec(mod .. " + P", bin .. "screenshot.sh fullscreen-save")
exec(mod .. " + SHIFT + P", bin .. "screenshot.sh region")
exec(mod .. " + CTRL + P", bin .. "screenshot.sh fullscreen-copy")
exec(mod .. " + CTRL + SHIFT + P", bin .. "screenshot.sh region-copy")

local locked = { locked = true }
local repeating = { locked = true, repeating = true }

exec("ALT + M", bin .. "volume.sh toggle")
exec("ALT + K", bin .. "volume.sh up", repeating)
exec("ALT + J", bin .. "volume.sh down", repeating)
exec("XF86AudioRaiseVolume", bin .. "volume.sh up", repeating)
exec("XF86AudioLowerVolume", bin .. "volume.sh down", repeating)
exec("XF86AudioMute", bin .. "volume.sh toggle", locked)
exec("XF86AudioPlay", "playerctl play-pause", locked)
exec("XF86AudioPrev", "playerctl previous", locked)
exec("XF86AudioNext", "playerctl next", locked)

exec("XF86MonBrightnessUp", "brightnessctl set 5%+", repeating)
exec("XF86MonBrightnessDown", "brightnessctl set 5%-", repeating)
exec("F8", "brightnessctl set 5%+", repeating)
exec("F7", "brightnessctl set 5%-", repeating)
