-- Applies all the keybinds from the declarative specification
local specs = require("modules.keybinds.declarative.specs")
local apply_keybinds = require("utils.keybinds.manager").apply_keybinds

for _, keybind_category in pairs(specs) do
    apply_keybinds(keybind_category.binds)
end
