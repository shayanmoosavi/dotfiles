-- Declarative specification for curve definitions
-- ==============================================================================================================================================

local curves = {
    -- Spring curve definitions
    {
        name = "windows_curve",
        specs = {
            type = "spring",
            mass = 1,
            stiffness = 40,
            dampening = 8
        }
    },
    {
        name = "workspace_curve",
        specs = {
            type = "spring",
            mass = 1,
            stiffness = 30,
            dampening = 8,
        }
    },
    {
        name = "layer_curve",
        specs = {
            type = "spring",
            mass = 1,
            stiffness = 80,
            dampening = 12,
        }
    }
}

return curves
