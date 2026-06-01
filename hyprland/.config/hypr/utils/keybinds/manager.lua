-- Keybinds manager module for Hyprland
-- ==============================================================================================================================================

local M = {}

local dispatcher = require("utils.keybinds.dispatchers")

-- Helper function to bind keybinds using the declarative specifications
local function bind(specs)
    -- Get the correct dispatcher from the declarative specs
    local key = specs.key
    local dsp_str = specs.dispatcher
    local desc = specs.description

    -- Get the options and arguments from the declarative specs
    local opts = specs.opts or nil
    local args = opts and opts.args or nil
    local repeating = opts and opts.repeating or nil


    local dsp = dispatcher[dsp_str]

    if not dsp then
        error("Invalid dispatcher: " .. tostring(dsp_str))
    end

    -- If there are no arguments, call the dispatcher directly. Otherwise, call it with the provided arguments.
    if not args then
        if repeating then
            hl.bind(key, dsp, {
                description = desc,
                repeating = true,
            })
        else
            hl.bind(key, dsp, {
                description = desc,
            })
        end
    else
        if repeating then
            hl.bind(key, dsp(args), {
                description = desc,
                repeating = true,
            })
        else
            hl.bind(key, dsp(args), {
                description = desc,
            })
        end
    end
end

function M.apply_keybinds(keybind_category)
    for _, spec in ipairs(keybind_category) do
        bind(spec)
    end
end

return M
