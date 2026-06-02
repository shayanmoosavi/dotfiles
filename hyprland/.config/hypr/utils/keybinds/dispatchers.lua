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

    -- For window management
    ["window.close"] = hl.dsp.window.close(),
    ["window.float"] = hl.dsp.window.float,
    ["window.fullscreen"] = hl.dsp.window.fullscreen,
    ["window.cycle_next"] = hl.dsp.window.cycle_next(),
    ["window.drag"] = hl.dsp.window.drag(),
    ["window.resize"] = hl.dsp.window.resize,
    ["window.swap"] = hl.dsp.window.swap,
    ["window.move"] = hl.dsp.window.move,
    ["window.pseudo"] = hl.dsp.window.pseudo,

    -- For group management
    ["group.toggle"] = hl.dsp.group.toggle(),
    ["group.next"] = hl.dsp.group.next(),

    -- For dwindle layout
    ["layout"] = hl.dsp.layout,

    -- For changing focus
    ["focus"] = hl.dsp.focus,
}

return dispatchers
