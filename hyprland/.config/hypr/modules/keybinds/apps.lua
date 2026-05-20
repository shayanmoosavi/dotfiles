-- Application Keybinds
-- ==============================================================================================================================================

local default = require("modules.keybinds.defaults")

-- Launch terminal
hl.bind(default.MainMod .. " + " .. "Return", hl.dsp.exec_cmd(default.Terminal), {
	description = "Launch terminal",
})

-- Launch Application Launcher
hl.bind(default.MainMod .. " + " .. "Space", hl.dsp.exec_cmd("rofi -show drun"), {
	description = "Launch Application Launcher",
})

-- Launch File Manager
hl.bind(default.MainMod .. " + " .. "Shift + Return", hl.dsp.exec_cmd(default.FileManager), {
	description = "Launch File Manager",
})

-- Launch Browser
hl.bind(default.MainMod .. " + " .. "B", hl.dsp.exec_cmd(default.Browser), {
	description = "Launch Browser",
})

-- Launch Clipboard Manager
local clipse_cmd = default.Terminal .. "--class clipse -e clipse"
hl.bind(default.MainMod .. " + " .. "V", hl.dsp.exec_cmd(clipse_cmd), {
	description = "Launch Clipboard Manager",
})

-- # Change Wallpaper
-- bind = $mainMod, W, exec, ~/.config/hypr/scripts/Wallpaper.sh

-- TODO: Migrate Wallpaper script to Lua
