-- Declarative specification for curve definitions
-- ==============================================================================================================================================

local curves = {
    -- Spring curve definitions
    windows_curve = {
        type = "spring",
        mass = 1,
        stiffness = 200,
        dampening = 16
    },
    workspace_curve = {
        type = "spring",
        mass = 1,
        stiffness = 160,
        dampening = 16
    },
    layer_curve = {
        type = "spring",
        mass = 1,
        stiffness = 160,
        dampening = 18
    }
}

return curves
