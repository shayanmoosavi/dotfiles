-- Declarative specification for setting animation curves
-- ==============================================================================================================================================

-- Importing curve definitions
local curves = require("modules.animations.declarative.curves")

-- Internal helpers
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Get curve name from definitions
local function get_curve(name)
    if curves[name] ~= nil then
        return name
    else
        error("Invalid curve name: " .. name)
    end
end

-- Declaring specs
-- --------------------------------------------------------------------------------------------------------------------------------------

local animations = {
    -- Setting animation curves
    {
        leaf = "windows",
        enabled = true,
        speed = 6,
        spring = get_curve("windows_curve"),
        style = "popin"
    },
    {
        leaf = "workspaces",
        enabled = true,
        speed = 6,
        spring = get_curve("workspace_curve"),
        style = "slidefade 70%"
    },
    {
        leaf = "layers",
        enabled = true,
        speed = 4,
        spring = get_curve("layer_curve"),
        style = "slide right"
    }
}

return animations
