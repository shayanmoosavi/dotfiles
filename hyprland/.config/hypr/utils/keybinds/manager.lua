-- Keybinds manager module for Hyprland
-- ==============================================================================================================================================

local M = {}

local dispatcher = require("utils.keybinds.dispatchers")

-- Helper function to bind keybinds using the declarative specifications
function M.bind(specs)
    -- Get the correct dispatcher from the declarative specs
    local key = specs.key
    local dsp_str = specs.dispatcher
    local args = specs.args
    local desc = specs.description

    local dsp = dispatcher[dsp_str]

    if not dsp then
        error("Invalid dispatcher: " .. tostring(dsp_str))
    end

    -- If there are no arguments, call the dispatcher directly. Otherwise, call it with the provided arguments.
    if not args then
        hl.bind(key, dsp, {
            description = desc,
        })
    else
        hl.bind(key, dsp(args), {
            description = desc,
        })
    end
end

return M
