-- Declarative layer rules for enforcing animation styles for certain layers
-- ==============================================================================================================================================

local anim_layers = {
    -- Rofi
    {
        name = "popin-rofi",
        match = {
            namespace = "rofi"
        },
        animation = "popin"
    },
    -- Logout dialogue (replace with your preferred logout dialogue)
    {
        name = "slide-top-logout-dialog",
        match = {
            namespace = "logout_dialog"
        },
        animation = "slide top"
    }
}

return anim_layers
