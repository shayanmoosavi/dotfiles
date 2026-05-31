-- Application Keybinds
-- ==============================================================================================================================================

-- Importing the declarative keybind specs and the keybind manager
local app_keybinds = require("modules.keybinds.declarative.specs").apps
local bind = require("utils.keybinds.manager").bind

-- Applying the keybinds using the manager
for _, spec in ipairs(app_keybinds) do
    bind(spec)
end
