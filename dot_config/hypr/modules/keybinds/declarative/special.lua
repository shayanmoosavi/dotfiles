-- Declarative specification of keybinds for special function keys
-- ==============================================================================================================================================

local matugen = require("colors.matugen")

local special = {

    -- Volume Control
    -- --------------------------------------------------------------------------------------------------------------------------------------
    {
        key = "XF86AudioRaiseVolume",
        dispatcher = "volume.up",
        description = "Volume up",
        opts = { repeating = true },
    },
    {
        key = "XF86AudioLowerVolume",
        dispatcher = "volume.down",
        description = "Volume down",
        opts = { repeating = true },
    },
    {
        key = "XF86AudioMute",
        dispatcher = "volume.mute",
        description = "Mute volume",
    },

    -- Brightness Control
    -- --------------------------------------------------------------------------------------------------------------------------------------
    {
        key = "XF86MonBrightnessUp",
        dispatcher = "brightness.up",
        description = "Brightness up",
        opts = { repeating = true },
    },
    {
        key = "XF86MonBrightnessDown",
        dispatcher = "brightness.down",
        description = "Brightness down",
        opts = { repeating = true },
    },
}

return {
    section = "Special Keys",
    icon = "󰬍",
    binds = special,
}
