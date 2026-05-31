-- A lookup table to map the correct dispatcher to the correct keybind types
-- ==============================================================================================================================================

local volume_mod = require("utils.keybinds.volume")
local brightness_mod = require("utils.keybinds.brightness")

local dispatchers = {

    -- For executing commands
    ["exec"] = hl.dsp.exec_cmd,

    -- For volume control
    ["volume.up"] = volume_mod.up,
    ["volume.down"] = volume_mod.down,
    ["volume.mute"] = volume_mod.mute,

    -- For brightness control
    ["brightness.up"] = brightness_mod.up,
    ["brightness.down"] = brightness_mod.down,

    -- For the custom kill command
    ["kill"] = require("utils.keybinds.kill").kill,
}

return dispatchers
