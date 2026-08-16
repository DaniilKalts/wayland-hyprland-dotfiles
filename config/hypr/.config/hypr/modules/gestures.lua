hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.gesture({
    fingers = 4,
    direction = "left",
    action = function()
        hl.dispatch(hl.dsp.focus({
            monitor = "l",
        }))
    end,
})

hl.gesture({
    fingers = 4,
    direction = "right",
    action = function()
        hl.dispatch(hl.dsp.focus({
            monitor = "r",
        }))
    end,
})

hl.gesture({
    fingers = 3,
    direction = "down",
    action = function()
        hl.exec_cmd("~/.local/bin/toggle-window-visibility.sh hide")
    end,
})

hl.gesture({
    fingers = 3,
    direction = "up",
    action = function()
        hl.exec_cmd("~/.local/bin/toggle-window-visibility.sh show")
    end,
})
