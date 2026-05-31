-- Special Keys Keybinds
-- ==============================================================================================================================================

-- Importing the declarative keybind specs and the keybind manager
local special_keybinds = require("modules.keybinds.declarative.specs").special
local bind = require("utils.keybinds.manager").bind

-- Applying the keybinds using the manager
for _, spec in ipairs(special_keybinds) do
    bind(spec)
end
