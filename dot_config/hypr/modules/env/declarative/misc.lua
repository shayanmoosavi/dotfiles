-- Declarative specification for miscellaneous environment variables
-- ==============================================================================================================================================

local misc_specs = {
    -- Solving flickering in Electron / CEF apps
    {
        variable = "ELECTRON_OZONE_PLATFORM_HINT",
        value = "auto"
    }
}

return misc_specs
