-- Special Keys Keybinds
-- ==============================================================================================================================================

-- Importing the declarative keybind specs and the keybind manager
local special_keybinds = require("modules.keybinds.declarative.specs").special
local apply_keybinds = require("utils.keybinds.manager").apply_keybinds

-- Applying the keybinds using the manager
apply_keybinds(special_keybinds)
