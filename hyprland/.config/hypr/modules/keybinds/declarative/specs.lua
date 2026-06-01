-- Declarative specification of keybinds
-- ==============================================================================================================================================

-- Importing the keybind specs
local keybinds = {
    require("modules.keybinds.declarative.apps"),
    require("modules.keybinds.declarative.special"),
    require("modules.keybinds.declarative.hyprbinds")
}

return keybinds
