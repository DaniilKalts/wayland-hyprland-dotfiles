local modules = {
    "modules.monitors",
    "modules.autostart",
    "modules.environment",
    "modules.options",
    "modules.animations",
    "modules.gestures",
    "modules.rules",
    "modules.bindings",
}

for _, module in ipairs(modules) do
    require(module)
end
