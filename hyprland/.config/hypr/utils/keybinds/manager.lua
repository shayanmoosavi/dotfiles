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
    local opts = specs.opts or {}
    local args = opts.args
    local repeating = opts.repeating or false
    local mouse = opts.mouse or false

    local dsp = dispatcher[dsp_str]

    if not dsp then
        error("Invalid dispatcher: " .. tostring(dsp_str))
    end

    local bind_options = {
        description = desc,
        repeating = repeating,
        mouse = mouse,
    }
    -- If there are no arguments, call the dispatcher directly. Otherwise, call it with the provided arguments.
    if not args then
        hl.bind(key, dsp, bind_options)
    else
        hl.bind(key, dsp(args), bind_options)
    end
end

function M.apply_keybinds(keybind_category)
    for _, spec in ipairs(keybind_category) do
        bind(spec)
    end
end

return M
