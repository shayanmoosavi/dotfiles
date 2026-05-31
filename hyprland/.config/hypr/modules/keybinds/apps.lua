-- Application Keybinds
-- ==============================================================================================================================================

local default = require("modules.defaults")

-- Launch terminal
hl.bind(default.MainMod .. " + " .. "Return", hl.dsp.exec_cmd(default.Terminal), {
    description = "Launch terminal",
})

-- Launch Application Launcher
hl.bind(default.MainMod .. " + " .. "Space", hl.dsp.exec_cmd("rofi -show drun"), {
    description = "Launch Application Launcher",
})

-- Launch File Manager
hl.bind(default.MainMod .. " + " .. "SHIFT + Return", hl.dsp.exec_cmd(default.FileManager), {
    description = "Launch File Manager",
})

-- Launch Browser
hl.bind(default.MainMod .. " + " .. "B", hl.dsp.exec_cmd(default.Browser), {
    description = "Launch Browser",
})

-- Launch Clipboard Manager
local clipse_cmd = default.Terminal .. " --class clipse -e clipse"
hl.bind(default.MainMod .. " + " .. "V", hl.dsp.exec_cmd(clipse_cmd), {
    description = "Launch Clipboard Manager",
})

-- # Change Wallpaper
local scripts_dir = os.getenv("HOME") .. "/.config/hypr/scripts/"
local wallpaper_cmd_prefix = default.Terminal .. " --title 'Wallpaper Picker' -e "
local wallpaper_cmd = wallpaper_cmd_prefix .. "python3 " .. scripts_dir .. "wallpaper.py"

hl.bind(default.MainMod .. " + " .. "W", hl.dsp.exec_cmd(wallpaper_cmd), {
    description = "Change Wallpaper"
})
