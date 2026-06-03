-- Declarative specification for XDG environment variables
-- ==============================================================================================================================================
-- Copied from Hyprland wiki
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

local xdg_specs = {
    {
        variable = "XDG_CURRENT_DESKTOP",
        value = "Hyprland",
    },
    {
        variable = "XDG_SESSION_TYPE",
        value = "wayland",
    },
    {
        variable = "XDG_SESSION_DESKTOP",
        value = "Hyprland",
    },
    {
        variable = "XDG_MENU_PREFIX",
        value = "arch-",
    }
}

return xdg_specs
