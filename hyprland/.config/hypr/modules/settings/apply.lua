-- Module to apply the Hyprland settings
-- ==============================================================================================================================================

-- Importing declarative specs
local settings_specs = require("modules.settings.declarative.specs")

-- Internal helpers
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Apply the hyprland settings
local function apply_settings(specs)
    hl.config(specs)
end

-- Registering the defined gestures
local function register_gesture(specs)
    hl.gesture(specs)
end

-- Applying the settings
-- --------------------------------------------------------------------------------------------------------------------------------------

for category, specs in pairs(settings_specs) do
    if category == "Gestures" then
        for _, gesture_specs in ipairs(specs) do
            register_gesture(gesture_specs)
        end
    else
        apply_settings(specs)
    end
end
