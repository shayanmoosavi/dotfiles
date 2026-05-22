-- Brightness Control Module for Hyprland
-- ==============================================================================

local M = {}

-- Importing common helpers
local exec = require("utils.common").exec
local safe_exec = require("utils.common").safe_exec


-- Icons directory
local icons_dir = os.getenv("HOME") .. "/.config/swaync/icons/"

-- Internal helpers
-- ----------------------------------------------------------------------

-- Get the current brightness level.
local function get_brightness()
    return tonumber(exec("brightnessctl get"))
end

-- Get the maximum brightness level.
local function get_max_brightness()
    return tonumber(exec("brightnessctl max"))
end

-- Get brightness percentage.
local function get_brightness_percentage()
    return math.floor(((get_brightness() / get_max_brightness()) * 100))
end

-- Determine brightness icon based on percentage.
local function get_brightness_icon(percentage)
    local icon
    if percentage >= 80 then
        icon = icons_dir .. "brightness-100.png"
    elseif percentage >= 60 then
        icon = icons_dir .. "brightness-80.png"
    elseif percentage >= 40 then
        icon = icons_dir .. "brightness-60.png"
    elseif percentage >= 20 then
        icon = icons_dir .. "brightness-40.png"
    else
        icon = icons_dir .. "brightness-20.png"
    end

    return icon
end

-- Send a libnotify desktop notification with the current brightness level.
local function notify(percentage)
    local icon = get_brightness_icon(percentage)
    local title = "Brightness: " .. percentage .. "%"

    safe_exec(string.format(
        'notify-send -t 2000'
        .. ' -h string:x-canonical-private-synchronous:brightness'
        .. ' -h int:value:%d'
        .. ' "%s" "" -i "%s"',
        percentage, title, icon)
    )
end

-- Public API
-- ----------------------------------------------------------------------

-- Increase the brightness by 5 percent
function M.up()
    os.execute("brightnessctl set 5%+")

    -- Get current brightness percentage
    local percentage = get_brightness_percentage()

    -- Notify the user
    notify(percentage)
end

-- Decrease the brightness by 5 percent
function M.down()
    os.execute("brightnessctl set 5%-")

    -- Get current brightness percentage
    local percentage = get_brightness_percentage()

    -- Notify the user
    notify(percentage)
end

return M
