-- Input & Gestures
-- ==============================================================================================================================================

-- Importing declarative specs
local decl_settings = "modules.settings.declarative"
local input = require(decl_settings .. ".input")
local gestures = require(decl_settings .. ".gestures")

-- Keyboard layouts and touchpad settings
hl.config(input)

-- Touchpad gestures
-- ---------------------------------------------------------------------

for _, gesture in ipairs(gestures) do
    hl.gesture(gesture)
end
