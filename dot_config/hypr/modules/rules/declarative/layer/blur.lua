-- Declarative layer rules for enabling blur for certain layers
-- ==============================================================================================================================================

local blur_layers = {
    -- Rofi
    {
        name = "blur-rofi",
        match = {
            namespace = "rofi"
        },
        blur = true,
        xray = true,
        dim_around = true,
        ignore_alpha = 0
    },

    -- Notifications
    {
        name = "blur-notifications",
        match = {
            namespace = "notifications"
        },
        blur = true
    },

    -- Notification Center (replace with your preferred notification center)
    {
        name = "blur-notification-center",
        match = {
            namespace = "^(swaync-control-center|swaync-notification-window)$"
        },
        blur = true,
        ignore_alpha = 0.5
    },

    -- Logout dialogue (replace with your preferred logout dialogue)
    {
        name = "blur-logout-dialog",
        match = {
            namespace = "logout_dialog"
        },
        blur = true,
        ignore_alpha = 0.2
    }
}

return blur_layers
