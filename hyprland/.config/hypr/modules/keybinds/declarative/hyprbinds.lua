-- Declarative specification for Hyprland core keybinds
-- ==============================================================================================================================================

-- MainMod key
local mainMod = require("modules.defaults").MainMod

local script_dir = os.getenv("HOME") .. "/.config/hypr/scripts"

local hyprbinds = {
    -- Session Control
    -- --------------------------------------------------------------------------------------------------------------------------------------

    -- Exit Hyprland gracefully with hyprshutdown (requires hyprshutdown package)
    --[[ If you experience blackscreen / hang when logging out with NVIDIA GPU and SDDM display manager,
        see the Hyprland wikipage for troubleshooting:
        https://wiki.hypr.land/Hypr-Ecosystem/hyprshutdown/#troubleshooting
    ]]
    {
        key = mainMod .. " + " .. "SHIFT + Escape",
        dispatcher = "exec",
        opts = { args = "hyprshutdown" },
        description = "Exit Hyprland gracefully with hyprshutdown (requires hyprshutdown package)",
    },
    {
        key = mainMod .. " + " .. "Escape",
        dispatcher = "exec",
        opts = { args = "wlogout" },
        description = "Wlogout Menu",
    },
    {
        key = mainMod .. " + " .. "SHIFT + L",
        dispatcher = "exec",
        opts = { args = "pidof hyprlock || hyprlock" },
        description = "Lock screen",
    },

    -- Hyprland Control
    -- --------------------------------------------------------------------------------------------------------------------------------------
    {
        key = mainMod .. " + " .. "Q",
        dispatcher = "window.close",
        description = "Close active window",
    },
    {
        key = mainMod .. " + " .. "SHIFT + Q",
        dispatcher = "kill",
        description = "Kill active window",
    },
    {
        key = mainMod .. " + " .. "R",
        dispatcher = "exec",
        opts = { args = "python3 " .. script_dir .. "/refresh.py" },
        description = "Refresh",
    },
    {
        key = mainMod .. " + " .. "F",
        dispatcher = "window.float",
        opts = {
            args = { action = "toggle" },
        },
        description = "Toggle Floating Window",
    },
    {
        key = mainMod .. " + " .. "SHIFT + F",
        dispatcher = "window.fullscreen",
        opts = {
            args = { action = "toggle" },
        },
        description = "Toggle Fullscreen",
    },
    {
        key = "ALT + TAB",
        dispatcher = "window.cycle_next",
        opts = {
            repeating = true,
        },
        description = "Cycle through windows",
    },
    {
        key = mainMod .. " + " .. "G",
        dispatcher = "group.toggle",
        description = "Toggle active window to group",
    },
    {
        key = mainMod .. " + " .. "CTRL + TAB",
        dispatcher = "group.next",
        opts = {
            repeating = true,
        },
        description = "Cycle through windows in a group",
    },
    {
        key = mainMod .. " + " .. "mouse:272",
        dispatcher = "window.drag",
        opts = {
            mouse = true,
        },
        description = "Drag window",
    },

    -- Dwindle layout specific keybinds
    -- --------------------------------------------------------------------------------------------------------------------------------------
    {
        key = mainMod .. " + " .. "P",
        dispatcher = "window.pseudo",
        opts = {
            args = { action = "toggle" },
        },
        description = "Toggle pseudotile",
    },
    {
        key = mainMod .. " + " .. "I",
        dispatcher = "layout",
        opts = {
            args = "togglesplit",
        },
        description = "Toggle split",
    },
}

-- Dynamic insertions into the keybinds table for commands that require some setup
-- ---------------------------------------------------------------------------------------------------------------------

local directions = {
    left = {
        move_key = "H",
        resize_key = "left",
        x = -20,
        y = 0,
        focus_dir = "l",
    },
    right = {
        move_key = "L",
        resize_key = "right",
        x = 20,
        y = 0,
        focus_dir = "r",
    },
    up = {
        move_key = "K",
        resize_key = "up",
        x = 0,
        y = -20,
        focus_dir = "u",
    },
    down = {
        move_key = "J",
        resize_key = "down",
        x = 0,
        y = 20,
        focus_dir = "d",
    }
}

for direction, properties in pairs(directions) do
    -- Resize active window
    table.insert(hyprbinds, {
        key = mainMod .. " + SHIFT + " .. properties.resize_key,
        dispatcher = "window.resize",
        opts = {
            args = {
                x = properties.x,
                y = properties.y,
                relative = true,
            },
            repeating = true,
        },
        description = "Resize active window (" .. direction .. ")"
    })

    -- Swap active window
    table.insert(hyprbinds, {
        key = mainMod .. " + " .. properties.move_key,
        dispatcher = "window.swap",
        opts = {
            args = { direction = properties.focus_dir },
        },
        description = "Swap active window (" .. direction .. ")"
    })

    -- Move focus
    table.insert(hyprbinds, {
        key = mainMod .. " + CTRL + " .. properties.move_key,
        dispatcher = "focus",
        opts = {
            args = { direction = properties.focus_dir },
        },
        description = "Move focus (" .. direction .. ")"
    })
end

return {
    section = "Desktop",
    binds = hyprbinds,
}
