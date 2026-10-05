-- Declarative specification of Hyprland settings
-- ==============================================================================================================================================

-- Importing declarative specs
local decl_settings = "modules.settings.declarative"
local specs = {
    Decorations = require(decl_settings .. ".decorations"),
    Input = require(decl_settings .. ".input"),
    Gestures = require(decl_settings .. ".gestures"),
    Other = require(decl_settings .. ".other"),
}

return specs
