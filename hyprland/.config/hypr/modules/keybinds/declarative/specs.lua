-- Declarative specification of keybinds
-- ==============================================================================================================================================

local defaults = require("modules.defaults")

local mainMod = defaults.MainMod
local terminal = defaults.Terminal
local file_manager = defaults.FileManager
local browser = defaults.Browser

local scripts_dir = os.getenv("HOME") .. "/.config/hypr/scripts/"

local keybinds = {
    apps = {
        {
            key = mainMod .. " + " .. "Return",
            dispatcher = "exec",
            args = terminal,
            description = "Launch terminal",
        },
        {
            key = mainMod .. " + " .. "Space",
            dispatcher = "exec",
            args = "rofi -show drun",
            description = "Launch Application Launcher",
        },
        {
            key = mainMod .. " + " .. "SHIFT + Return",
            dispatcher = "exec",
            args = file_manager,
            description = "Launch File Manager",
        },
        {
            key = mainMod .. " + " .. "B",
            dispatcher = "exec",
            args = browser,
            description = "Launch Browser",
        },
        {
            key = mainMod .. " + " .. "V",
            dispatcher = "exec",
            args = terminal .. " --class clipse -e clipse",
            description = "Launch Clipboard Manager",
        },

    }
}

-- Dynamic insertions into the keybinds table for commands that require some setup
-- ---------------------------------------------------------------------------------------------------------------------

-- Change Wallpaper
local wallpaper_cmd_prefix = terminal .. " --title 'Wallpaper Picker' -e "
local wallpaper_cmd = wallpaper_cmd_prefix .. "python3 " .. scripts_dir .. "wallpaper.py"

table.insert(keybinds.apps, {
    key = mainMod .. " + " .. "W",
    dispatcher = "exec",
    args = wallpaper_cmd,
    description = "Change Wallpaper",
})

return keybinds
