-- Special Keys Keybinds
-- ==============================================================================================================================================

-- Scripts directory
local script_dir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Import required helpers
local volume = require("utils.volume")
local brightness = require("utils.brightness")

-- Volume Control
-- --------------------------------------------------------------------------------------------------------------------------------------

hl.bind("XF86AudioRaiseVolume", volume.up, {
    repeating = true,
    description = "Volume up"
})

hl.bind("XF86AudioLowerVolume", volume.down, {
    repeating = true,
    description = "Volume down"
})

hl.bind("XF86AudioMute", volume.mute, {
    description = "Mute volume"
})

-- Brightness Control
-- --------------------------------------------------------------------------------------------------------------------------------------

hl.bind("XF86MonBrightnessUp", brightness.up, {
    description = "Brightness up"
})

hl.bind("XF86MonBrightnessDown", brightness.down, {
    description = "Brightness down"
})
