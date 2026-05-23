-- Layer rules
-- ==============================================================================================================================================

-- Layer rule specs for blur
local blur_specs = require("modules.rules.declarative").Blur

-- Apply blur rules
for _, spec in pairs(blur_specs) do
    hl.layer_rule(spec)
end
