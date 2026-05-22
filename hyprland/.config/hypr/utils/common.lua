-- Common utilities
-- ==============================================================================

local M = {}

-- Internal helpers
-- ----------------------------------------------------------------------

-- Strip surrounding whitespace from a string.
local function strip(str)
    -- (necessary to store into a variable because of the two return values)
    local stripped_str = str:gsub("^%s+", ""):gsub("%s+$", "")
    return stripped_str
end

-- Public API
-- ----------------------------------------------------------------------

-- Run a shell command and return its trimmed stdout.
function M.exec(cmd)
    local handle = io.popen(cmd)
    if not handle then return "" end
    local out = handle:read("*a")
    handle:close()
    return strip(out)
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
