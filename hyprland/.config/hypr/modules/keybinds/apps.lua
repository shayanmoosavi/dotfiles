-- Application Keybinds
-- ==============================================================================================================================================

-- Importing the declarative keybind specs and the keybind manager
local app_keybinds = require("modules.keybinds.declarative.specs").apps
local apply_keybinds = require("utils.keybinds.manager").apply_keybinds

-- Applying the keybinds using the manager
apply_keybinds(app_keybinds)
