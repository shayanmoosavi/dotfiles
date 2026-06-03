-- Declarative specification for window rules and layer rules
-- ==============================================================================================================================================

-- Importing complete window rule specs
local decl_rules = "modules.rules.declarative"
local window_specs = require(decl_rules .. ".window.specs")
local layer_specs = require(decl_rules .. ".layer.specs")

local specs = {
    Window = window_specs,
    Layer = layer_specs,
}

return specs
