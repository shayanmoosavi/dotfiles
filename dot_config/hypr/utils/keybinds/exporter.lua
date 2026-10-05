-- JSON exporter module for Hyprland
-- ==============================================================================================================================================

local json = require("utils.json")
local M = {}

function M.export(keybinds_data, target_path)
    -- Wrapping the write operation in standard I/O ensures we don't crash Hyprland if permission or path issues occur.
    local file = io.open(target_path, "w")
    if not file then
        print("[Error] Could not open file path for writing keybinds: " .. tostring(target_path))
        return false
    end

    -- Using pcall (protected call) ensures that if an unexpected serialization error occurs, your desktop environment still loads.
    local success, encoded = pcall(json.encode, keybinds_data)
    if success then
        file:write(encoded)
        file:close()
        return true
    else
        print("[Error] Failed to serialize keybinds to JSON: " .. tostring(encoded))
        file:close()
        return false
    end
end

return M
