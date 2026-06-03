-- Layer rules
-- ==============================================================================================================================================

-- Internal helpers
-- --------------------------------------------------------------------------------------------------------------------------------------

local function apply_rule(specs)
    for _, spec in pairs(specs) do
        hl.layer_rule(spec)
    end
end

-- Applying layer rules
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Layer rule specs for blur
local layer_specs = require("modules.rules.declarative.specs").Layer

for _, specs in pairs(layer_specs) do
    apply_rule(specs)
end
