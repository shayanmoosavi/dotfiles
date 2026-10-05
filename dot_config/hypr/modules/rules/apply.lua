-- Module to apply the Hyprland rules
-- ==============================================================================================================================================

-- Importing helpers
local helpers = require("utils.rules.apply_rules")

-- Importing declarative rules specs
local rules_specs = require("modules.rules.declarative.specs")

-- Initializing tags
helpers.init_tags()

-- Applying the rules
for category, specs in pairs(rules_specs) do
    if category == "Window" then
        helpers.apply_window_rules(specs)
    elseif category == "Layer" then
        helpers.apply_layer_rules(specs)
    end
end
