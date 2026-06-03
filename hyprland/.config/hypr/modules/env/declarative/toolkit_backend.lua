-- Declarative specification for toolkit backend environment variables
-- ==============================================================================================================================================
-- Copied from Hyprland wiki
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

local toolkit_backend = {
    -- GTK: Use Wayland if available; if not, try X11 and then any other GDK backend.
    {
        variable = "GDK_BACKEND",
        value = "wayland,x11,*",
    },

    -- Qt: Use Wayland if available, fall back to X11 if not.
    {
        variable = "QT_QPA_PLATFORM",
        value = "wayland;xcb",
    },

    -- Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
    {
        variable = "SDL_VIDEODRIVER",
        value = "wayland",
    },

    -- Clutter package already has Wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
    {
        variable = "CLUTTER_BACKEND",
        value = "wayland",
    }
}

return toolkit_backend
