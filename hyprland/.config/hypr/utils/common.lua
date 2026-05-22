-- Common utilities
-- ==============================================================================

local M = {}

-- Run a shell command and return its trimmed stdout.
function M.exec(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local out = handle:read("*a")
    handle:close()
    -- Strip surrounding whitespace so callers get clean strings/numbers.
    return out:gsub("^%s+", ""):gsub("%s+$", "")
end

-- Play the system volume-change sound.
function M.play_sound(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        os.execute("paplay " .. path .. " &")
    end
end

return M
