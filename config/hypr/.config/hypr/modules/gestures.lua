local function focusMonitor(monitor)
    return function()
        hl.dispatch(hl.dsp.focus({ monitor = monitor }))
    end
end

local function toggleWindows(action)
    return function()
        hl.exec_cmd("~/.local/bin/toggle-window-visibility.sh " .. action)
    end
end

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", action = toggleWindows("hide") })
hl.gesture({ fingers = 3, direction = "up", action = toggleWindows("show") })
hl.gesture({ fingers = 4, direction = "left", action = focusMonitor("l") })
hl.gesture({ fingers = 4, direction = "right", action = focusMonitor("r") })
