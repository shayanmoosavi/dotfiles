-- Declarative specification of keybinds
-- ==============================================================================================================================================

-- Importing the keybind specs
local apps = require("modules.keybinds.declarative.apps")
local special = require("modules.keybinds.declarative.special")

local keybinds = {
    apps = apps,
    special = special,
}

return keybinds
