-- Declarative specification for curve definitions
-- ==============================================================================================================================================

local curves = {
    -- Spring curve definitions
    windows_curve = {
        type = "spring",
        mass = 1,
        stiffness = 40,
        dampening = 8
    },
    workspace_curve = {
        type = "spring",
        mass = 1,
        stiffness = 30,
        dampening = 8
    },
    layer_curve = {
        type = "spring",
        mass = 1,
        stiffness = 80,
        dampening = 12
    }
}

return curves
