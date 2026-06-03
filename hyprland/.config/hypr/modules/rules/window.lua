-- Window rules
-- ==============================================================================================================================================

-- Import helpers
local tags = require("utils.rules.tags")

-- Internal helpers
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Helper function for floating and centering windows
local function float_and_center(specs)
    local float_and_center_specs = {
        float = true,
        center = true
    }

    for k, v in pairs(specs) do
        float_and_center_specs[k] = v
    end

    hl.window_rule(float_and_center_specs)
end

-- Helper function for applying window rules
local function apply_rules(specs, is_float_center)
    local is_float_center = is_float_center or false

    if is_float_center then
        for _, spec in pairs(specs) do
            float_and_center(spec)
        end
    else
        for _, spec in pairs(specs) do
            hl.window_rule(spec)
        end
    end
end

-- Applying window rules
-- --------------------------------------------------------------------------------------------------------------------------------------

tags.tag_browser_type()
tags.tag_games()
tags.tag_settings()

-- Importing declarative window rule specs
local window_specs = require("modules.rules.declarative.specs").Window

for category, specs in pairs(window_specs) do
    if category == "FloatCenter" then
        apply_rules(specs, true)
    else
        apply_rules(specs)
    end
end

-- Move to workspace window rules
local workspace_categories = {
    browser = 1,
    social = 3,
    ide = 4,
    gamelauncher = 5,
    games = 6,
}

for category, workspace in pairs(workspace_categories) do
    hl.window_rule({
        name = "move-" .. category .. "-to-" .. workspace,
        match = {
            tag = category .. "*",
        },
        workspace = workspace,
    })
end
