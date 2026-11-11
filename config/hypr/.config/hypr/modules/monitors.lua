hl.monitor({
  output = "eDP-1",
  disabled = false,
})

hl.monitor({
  output = "DP-9",
  mode = "3840x2160@160",
  position = "1920x0",
  scale = 2,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "3840x2160@60",
  position = "0x0",
  scale = 2,
})

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

hl.workspace_rule({
  workspace = "1",
  monitor = "HDMI-A-1",
  default = true,
})

hl.workspace_rule({
  workspace = "2",
  monitor = "HDMI-A-1",
})

hl.workspace_rule({
  workspace = "3",
  monitor = "HDMI-A-1",
})

hl.workspace_rule({
  workspace = "4",
  monitor = "HDMI-A-1",
})

hl.workspace_rule({
  workspace = "5",
  monitor = "DP-9",
  default = true,
})

hl.workspace_rule({
  workspace = "6",
  monitor = "DP-9",
})

hl.workspace_rule({
  workspace = "7",
  monitor = "DP-9",
})

hl.workspace_rule({
  workspace = "8",
  monitor = "DP-9",
})
