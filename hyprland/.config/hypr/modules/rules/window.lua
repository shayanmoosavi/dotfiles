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

-- No transparency and blur for multimedia
hl.window_rule({
    name = "no-transparency-multimedia",
    match = {
        tag = "multimedia*",
    },
    no_blur = true,
    opacity = "1.0 override",
})

-- No blur for games
hl.window_rule({
    name = "no-blur-games",
    match = {
        tag = "games*",
    },
    no_blur = true,
    fullscreen = true,
})

-- Prevent idle for fullscreen windows
hl.window_rule({
    name = "no-idle-fullscreen",
    match = {
        fullscreen = true,
    },
    idle_inhibit = "fullscreen",
})

-- Window rule specs for floating and centering windows
local float_center_specs = require("modules.rules.declarative").FloatCenter

-- Apply float center window rule specs
for _, specs in pairs(float_center_specs) do
    float_and_center(specs)
end

-- Picture-in-picture
hl.window_rule({
    name = "picture-in-picture",
    match = {
        title = "Picture-in-Picture",
    },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
})

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
