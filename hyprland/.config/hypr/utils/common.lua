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
    -- (necessary to store into a variable because of the two return values)
    local cleaned_out = out:gsub("^%s+", ""):gsub("%s+$", "")
    return cleaned_out
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
