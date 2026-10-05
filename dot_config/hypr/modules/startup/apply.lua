-- Module to apply startup configuration
-- ==============================================================================================================================================

-- Importing the declarative specs
local specs = require("modules.startup.declarative.specs")

hl.on("hyprland.start", function()
    for _, category in pairs(specs) do
        for _, entry in ipairs(category) do
            hl.exec_cmd(entry.exec)
        end
    end
end
)
