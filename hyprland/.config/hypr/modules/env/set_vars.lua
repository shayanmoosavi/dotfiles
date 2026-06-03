-- Environment Variables
-- ==============================================================================================================================================

local decl_specs = require("modules.env.declarative.specs")

for _, category_specs in ipairs(decl_specs) do
    for _, specs in pairs(category_specs) do
        hl.env(specs.variable, specs.value)
    end
end
