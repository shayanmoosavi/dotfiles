local specs = require("modules.keybinds.declarative.specs")
local apply_keybinds = require("utils.keybinds.manager").apply_keybinds
local exporter = require("utils.keybinds.exporter")

-- Apply the keybinds
for _, keybind_category in pairs(specs) do
    apply_keybinds(keybind_category)
end

require("modules.keybinds.hyprbinds")
require("modules.keybinds.workspaces")

-- Dump the fully evaluated table to a file for keybinds_reference.py
local json_path = os.getenv("HOME") .. "/.config/hypr/scripts/resources/keybinds.json"
exporter.export(specs, json_path)
