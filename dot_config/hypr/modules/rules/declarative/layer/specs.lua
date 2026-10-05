-- Declarative specification for layer rules
-- ==============================================================================================================================================

local decl_layers = "modules.rules.declarative.layer"
local blur = require(decl_layers .. ".blur")
local anim = require(decl_layers .. ".anim")

local layer_specs = {
    Blur = blur,
    Anim = anim
}

return layer_specs
