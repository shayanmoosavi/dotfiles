-- Window rules
-- ==============================================================================================================================================

-- Import helpers
local tags = require("utils.rules.tags")

-- Tags
-- --------------------------------------------------------------------------------------------------------------------------------------
-- Tagging certain grouped windows for easier window rules

tags.tag_browser_type()
tags.tag_games()
tags.tag_settings()

-- Window rule specs for tagging different window categories
local tag_specs = require("modules.rules.declarative").Tags

-- Apply window rules
for _, spec in pairs(tag_specs) do
    hl.window_rule(spec)
end

-- Window rules
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Helper function for floating and centering windows
local function float_and_center(specs)
    local specs = specs or {}
    specs.name = specs.name or "float-center"
    local float_and_center_specs = {
        float = true,
        center = true
    }

    for k, v in pairs(specs) do
        float_and_center_specs[k] = v
    end

    hl.window_rule(float_and_center_specs)
end

-- Window rule specs for no blur
local no_blur_specs = require("modules.rules.declarative").NoBlur

-- Apply window rules
for _, spec in pairs(no_blur_specs) do
    hl.window_rule(spec)
end

-- Window rule specs for no idle
local no_idle_specs = require("modules.rules.declarative").NoIdle

-- Apply no idle window rule specs
for _, spec in pairs(no_idle_specs) do
    hl.window_rule(spec)
end

-- Window rule specs for floating and centering windows
local float_center_specs = require("modules.rules.declarative").FloatCenter

-- Apply float center window rule specs
for _, specs in pairs(float_center_specs) do
    float_and_center(specs)
end

-- Window rule specs for picture-in-picture
local pip_specs = require("modules.rules.declarative").PiP

-- Apply picture-in-picture window rule specs
for _, spec in pairs(pip_specs) do
    hl.window_rule(spec)
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
