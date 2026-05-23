-- Window rules
-- ==============================================================================================================================================

-- Import helpers
local tags = require("utils.rules.tags")

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

-- Tags
-- --------------------------------------------------------------------------------------------------------------------------------------
-- Tagging certain grouped windows for easier window rules

tags.tag_browser_type()
tags.tag_games()
tags.tag_settings()

-- Window rule specs for tagging different window categories
local tag_specs = require("modules.rules.declarative").Tags

-- Apply window rules
apply_rules(tag_specs)

-- Window rules
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Window rule specs for no blur
local no_blur_specs = require("modules.rules.declarative").NoBlur

-- Apply window rules
apply_rules(no_blur_specs)

-- Window rule specs for no idle
local no_idle_specs = require("modules.rules.declarative").NoIdle

-- Apply no idle window rule specs
apply_rules(no_idle_specs)

-- Window rule specs for floating and centering windows
local float_center_specs = require("modules.rules.declarative").FloatCenter

-- Apply float center window rule specs
apply_rules(float_center_specs, true)

-- Window rule specs for picture-in-picture
local pip_specs = require("modules.rules.declarative").PiP

-- Apply picture-in-picture window rule specs
apply_rules(pip_specs)

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
