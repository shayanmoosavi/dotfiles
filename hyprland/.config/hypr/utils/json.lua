-- Simple JSON encoder utility module for Hyprland
-- ==============================================================================================================================================

local M = {}

-- Internal helpers
-- ----------------------------------------------------------------------

-- Convert a string to a JSON-escaped string
local function json_str(s)
    -- Escape backslash first, then double-quote, then control characters
    return '"' .. tostring(s)
        :gsub('\\', '\\\\')
        :gsub('"', '\\"')
        :gsub('\n', '\\n')
        :gsub('\r', '\\r')
        :gsub('\t', '\\t')
        .. '"'
end

-- Encode the keybind entry
local function encode_bind(bind)
    -- Only key and description are needed by the Python side;
    -- dispatcher and opts are Hyprland-only concerns.
    return string.format(
        '{"key":%s,"description":%s}',
        json_str(bind.key or ""),
        json_str(bind.description or "")
    )
end

-- Encode the section entry
local function encode_section(section)
    local bind_parts = {}
    for _, bind in ipairs(section.binds) do
        table.insert(bind_parts, encode_bind(bind))
    end

    return string.format(
        '{"section":%s,"icon":%s,"color":%s,"color_desc":%s,"color_sep":%s,"binds":[%s]}',
        json_str(section.section or "Undefined"),
        json_str(section.icon or "󰆧"),
        json_str(section.color or "#ffffff"),
        json_str(section.color_desc or section.color or "#ffffff"),
        json_str(section.color_sep or section.color or "#ffffff"),
        table.concat(bind_parts, ",")
    )
end

-- Public API
-- ----------------------------------------------------------------------

function M.encode(val)
    -- Build and emit the top-level array
    local section_parts = {}
    for _, section in pairs(val) do
        table.insert(section_parts, encode_section(section))
    end

    return "[" .. table.concat(section_parts, ",") .. "]"
end

return M
