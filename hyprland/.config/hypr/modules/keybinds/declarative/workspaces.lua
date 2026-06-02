-- Declarative specification for workspaces keybinds
-- ==============================================================================================================================================

-- MainMod Key
local mainMod = require("modules.defaults").MainMod

local workspaces = {
    {
        key = mainMod .. " + " .. "TAB",
        dispatcher = "focus",
        opts = {
            args = { workspace = "m+1" }
        },
        description = "Cycle next workspace on monitor",
    },
    {
        key = mainMod .. " + " .. "SHIFT + TAB",
        dispatcher = "focus",
        opts = {
            args = { workspace = "m-1" }
        },
        description = "Cycle previous workspace on monitor",
    },
    {
        key = mainMod .. " + " .. "period",
        dispatcher = "focus",
        opts = {
            args = { workspace = "e+1" }
        },
        description = "Cycle next open workspace",
    },
    {
        key = mainMod .. " + " .. "comma",
        dispatcher = "focus",
        opts = {
            args = { workspace = "e-1" }
        },
        description = "Cycle previous open workspace",
    },
    {
        key = mainMod .. " + " .. "bracketright",
        dispatcher = "window.move",
        opts = {
            args = { workspace = "+1" }
        },
        description = "Move active window to next workspace",
    },
    {
        key = mainMod .. " + " .. "bracketleft",
        dispatcher = "window.move",
        opts = {
            args = { workspace = "-1" }
        },
        description = "Move active window to previous workspace",
    },
}

-- Dynamic insertions into the keybinds table for commands that require some setup
-- ---------------------------------------------------------------------------------------------------------------------

-- Number keys key code mapping
local number_keys = {
    [1] = "code:10",
    [2] = "code:11",
    [3] = "code:12",
    [4] = "code:13",
    [5] = "code:14",
    [6] = "code:15",
    [7] = "code:16",
    [8] = "code:17",
    [9] = "code:18",
    [0] = "code:19",
}

for number, keycode in pairs(number_keys) do
    local desc_number = number == 0 and 10 or number

    -- Switch to specified workspace with mainMod + [0-9]
    table.insert(workspaces, {
        key = mainMod .. " + " .. keycode,
        dispatcher = "focus",
        opts = {
            args = { workspace = number }
        },
        description = "Switch to workspace " .. desc_number,
    })

    -- Move active window and follow to workspace with mainMod + SHIFT + [0-9]
    table.insert(workspaces, {
        key = mainMod .. " + " .. "SHIFT + " .. keycode,
        dispatcher = "window.move",
        opts = {
            args = { workspace = number }
        },
        description = "Move active window to workspace " .. desc_number,
    })

    -- Move active window to a workspace silently with mainMod + CTRL + [0-9]
    table.insert(workspaces, {
        key = mainMod .. " + " .. "CTRL + " .. keycode,
        dispatcher = "window.move",
        opts = {
            args = { workspace = number, follow = false }
        },
        description = "Move active window to workspace " .. desc_number .. " (silent)",
    })
end

return {
    section = "Workspaces",
    binds = workspaces,
}
