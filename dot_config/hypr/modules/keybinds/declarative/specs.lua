-- Declarative specification of keybinds
-- ==============================================================================================================================================

-- Importing the keybind specs
-- IMPORTANT: It's important to assign them to variables due to require function behavior
local apps = require("modules.keybinds.declarative.apps")
local special = require("modules.keybinds.declarative.special")
local hyprbinds = require("modules.keybinds.declarative.hyprbinds")
local workspaces = require("modules.keybinds.declarative.workspaces")

return {
    apps,
    special,
    hyprbinds,
    workspaces,
}
