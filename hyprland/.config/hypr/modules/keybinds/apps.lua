-- Application Keybinds
-- ==============================================================================================================================================

local default = require("hypr.modules.keybinds.defaults")

-- Launch terminal
hl.bind(default.MainMod .. " + " .. "Return", hl.dsp.exec_cmd(default.Terminal))

-- Launch Application Launcher
hl.bind(default.MainMod .. " + " .. "Space", hl.dsp.exec_cmd("rofi -show drun"))

-- Launch File Manager
hl.bind(default.MainMod .. " + " .. "Shift + Return", hl.dsp.exec_cmd(default.FileManager))

-- Launch Browser
hl.bind(default.MainMod .. " + " .. "B", hl.dsp.exec_cmd(default.Browser))

-- Launch Clipboard Manager
local clipse_cmd = default.Terminal .. "--class clipse -e clipse"
hl.bind(default.MainMod .. " + " .. "V", hl.dsp.exec_cmd(clipse_cmd))

-- # Change Wallpaper
-- bind = $mainMod, W, exec, ~/.config/hypr/scripts/Wallpaper.sh

-- TODO: Migrate Wallpaper script to Lua
