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

-- Non-blocking execution of a shell command.
function M.safe_exec(cmd)
    -- (Necessary for some commands such as 'notify-send')
    -- Sends the command to background and returns immediately.
    -- Otherwise, lua thread will be locked and hyprland will not respond.
    os.execute(cmd .. " &")
end

-- Play a sound from provided path.
function M.play_sound(path)
    local f = io.open(path, "r")
    if f then
        f:close()
        M.safe_exec("paplay " .. path)
    end
end

return M
