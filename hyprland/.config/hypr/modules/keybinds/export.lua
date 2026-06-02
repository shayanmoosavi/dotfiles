local specs = require("modules.keybinds.declarative.specs")
local exporter = require("utils.keybinds.exporter")

-- Dump the fully evaluated table to a file for keybinds_reference.py
local json_path = os.getenv("HOME") .. "/.config/hypr/scripts/resources/keybinds.json"
exporter.export(specs, json_path)
