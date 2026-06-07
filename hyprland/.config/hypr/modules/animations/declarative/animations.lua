-- Declarative specification for setting animation curves
-- ==============================================================================================================================================

-- Importing curve definitions
local curves = require("modules.animations.declarative.curves")

-- Importing helper functions
local get_curve = require("modules.animations.declarative.animations").get_curve

-- Declaring specs
-- --------------------------------------------------------------------------------------------------------------------------------------

local animations = {
    -- Setting animation curves
    {
        leaf = "windows",
        enabled = true,
        speed = 6,
        spring = get_curve(curves, "windows_curve"),
        style = "popin"
    },
    {
        leaf = "workspaces",
        enabled = true,
        speed = 6,
        spring = get_curve(curves, "workspace_curve"),
        style = "slidefade 70%"
    },
    {
        leaf = "layers",
        enabled = true,
        speed = 4,
        spring = get_curve(curves, "layer_curve"),
        style = "slide right"
    }
}

return animations
