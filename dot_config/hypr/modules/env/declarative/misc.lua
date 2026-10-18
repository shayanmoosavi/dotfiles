-- Declarative specification for miscellaneous environment variables
-- ==============================================================================================================================================

local misc_specs = {
    -- Solving flickering in Electron / CEF apps
    {
        variable = "ELECTRON_OZONE_PLATFORM_HINT",
        value = "auto",
    },
    -- Solving blur not applying in GTK 4.24+ apps (Fuck you GNOME)
    {
        variable = "GDK_WAYLAND_DISABLE",
        value = "ext_background_effect_manager_v1",
    },
}

return misc_specs
