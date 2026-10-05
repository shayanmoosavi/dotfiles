-- Declarative specification for Qt environment variables
-- ==============================================================================================================================================
-- Copied from Hyprland wiki
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

local qt_specs = {
    -- enables automatic scaling, based on the monitor's pixel density
    {
        variable = "QT_AUTO_SCREEN_SCALE_FACTOR",
        value = "1",
    },

    -- Tell Qt applications to use the Wayland backend, and fall back to X11 if Wayland is unavailable
    {
        variable = "QT_QPA_PLATFORM",
        value = "wayland;xcb",
    },

    -- Disables window decorations on Qt applications
    {
        variable = "QT_WAYLAND_DISABLE_WINDOWDECORATION",
        value = "1",
    },

    -- Tells Qt based applications to pick your theme from qt5ct, use with Kvantum.
    {
        variable = "QT_QPA_PLATFORMTHEME",
        value = "qt5ct",
    }
}

return qt_specs
