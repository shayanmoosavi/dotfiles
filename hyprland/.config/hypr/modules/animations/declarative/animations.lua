-- Declarative specification for setting animation curves
-- ==============================================================================================================================================

local animations = {
    -- Setting animation curves
    {
        leaf = "windows",
        enabled = true,
        speed = 6,
        name = "windows_curve",
        curve_type = "spring",
        style = "popin"
    },
    {
        leaf = "workspaces",
        enabled = true,
        speed = 6,
        name = "workspace_curve",
        curve_type = "spring",
        style = "slidefade 70%"
    },
    {
        leaf = "layers",
        enabled = true,
        speed = 4,
        name = "layer_curve",
        curve_type = "spring",
        style = "slide right"
    }
}

return animations
