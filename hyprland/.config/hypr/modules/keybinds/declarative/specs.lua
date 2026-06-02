-- Declarative specification of keybinds
-- ==============================================================================================================================================

-- Importing the keybind specs
local keybinds = {
    apps = require("modules.keybinds.declarative.apps"),
    special = require("modules.keybinds.declarative.special"),
    hyprbinds = require("modules.keybinds.declarative.hyprbinds"),
}

return keybinds
