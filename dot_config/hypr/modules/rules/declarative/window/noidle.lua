-- Declarative window rules for preventing idle
-- ==============================================================================================================================================

local noidle = {
    -- Prevent idle for fullscreen windows
    {
        name = "no-idle-fullscreen",
        match = {
            fullscreen = true,
        },
        idle_inhibit = "fullscreen",
    }
}

return noidle
