-- Declarative window rules for moving windows to workspaces
-- ==============================================================================================================================================

-- Window categories to workspace mappings
local workspace_categories = {
    browser = 1,
    social = 3,
    ide = 4,
    gamelauncher = 5,
    games = 6,
}

local move_to_workspace = {}

for category, workspace in pairs(workspace_categories) do
    table.insert(move_to_workspace, {
        name = "move-" .. category .. "-to-" .. workspace,
        match = {
            tag = category .. "*",
        },
        workspace = workspace,
    })
end

return move_to_workspace
