-- Utilities for animations

local M = {}

function M.Get_curve(curves, name)
    if curves[name] ~= nil then
        return name
    else
        error("Invalid curve name: " .. name)
    end
end

return M
