-- Declarative specification of gesture settings
-- ==============================================================================================================================================

local gestures = {
    -- Swipe horizontal to switch workspaces
    {
        fingers = 3,
        direction = "horizontal",
        action = "workspace"
    },

    -- Swipe up to close active window
    {
        fingers = 3,
        direction = "up",
        action = "close"
    }
}

return gestures
