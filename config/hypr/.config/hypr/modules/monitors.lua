hl.monitor({ output = "eDP-1", disabled = false })
hl.monitor({ output = "DP-9", mode = "3840x2160@160", position = "1920x0", scale = 2 })
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = 2 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

local workspaces = {
    ["HDMI-A-1"] = { 1, 2, 3, 4 },
    ["DP-9"] = { 5, 6, 7, 8 },
}

for monitor, ids in pairs(workspaces) do
    for _, id in ipairs(ids) do
        hl.workspace_rule({
            workspace = tostring(id),
            monitor = monitor,
        })
    end
end
