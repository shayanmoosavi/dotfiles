-- Helper functions for applying rules
-- ==============================================================================================================================================

local M = {}

-- Import helpers
local tags = require("utils.rules.tags")

-- Internal helpers
-- ...........................................................................................

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

-- Helper function for applying window rules for a category
local function apply_window_rules_category(specs, is_float_center)
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

-- Helper function for applying layer rules for a category
local function apply_layer_rules_category(specs)
    for _, spec in pairs(specs) do
        hl.layer_rule(spec)
    end
end

-- Public API
-- ...........................................................................................

-- Helper function to tag convenient window categories
function M.init_tags()
    tags.tag_browser_type()
    tags.tag_games()
    tags.tag_settings()
end

-- Helper function for applying all window rules
function M.apply_window_rules(specs)
    for category, window_specs in pairs(specs) do
        if category == "FloatCenter" then
            apply_window_rules_category(window_specs, true)
        else
            apply_window_rules_category(window_specs)
        end
    end
end

-- Helper function for applying all layer rules
function M.apply_layer_rules(specs)
    for _, layer_specs in pairs(specs) do
        apply_layer_rules_category(layer_specs)
    end
end

return M
