-- Simple JSON encoder utility module for Hyprland
-- ==============================================================================================================================================

local M = {}

-- Internal helpers
-- ----------------------------------------------------------------------

-- Determine if a table acts as an array
local function is_array(t)
    local i = 1
    for _ in pairs(t) do
        if t[i] == nil then return false end
        i = i + 1
    end
    return i > 1 or next(t) == nil
end

-- Escape special characters in a string
local function escape_str(s)
    local matches = {
        ['"'] = '\\"',
        ['\\'] = '\\\\',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t'
    }
    return s:gsub('["\\\b\f\n\r\t]', matches)
end

-- Public API
-- ----------------------------------------------------------------------

function M.encode(val)
    local t = type(val)

    if t == "string" then
        return '"' .. escape_str(val) .. '"'
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "table" then
        if is_array(val) then
            local parts = {}
            for _, v in ipairs(val) do
                table.insert(parts, M.encode(v))
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for k, v in pairs(val) do
                if type(k) == "string" then
                    table.insert(parts, '"' .. escape_str(k) .. '":' .. M.encode(v))
                end
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    else
        return "null"
    end
end

return M
