-- Hyprland Core Keybinds
-- ==============================================================================================================================================

-- MainMod key
local mainMod = require("modules.keybinds.defaults").MainMod

local kill = require("utils.keybinds.kill").kill

-- Session Control
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Exit Hyprland gracefully with hyprshutdown (requires hyprshutdown package)
--[[ If you experience blackscreen / hang when logging out with NVIDIA GPU and SDDM display manager,
see the Hyprland wikipage for troubleshooting:
https://wiki.hypr.land/Hypr-Ecosystem/hyprshutdown/#troubleshooting
]]
hl.bind(mainMod .. " + " .. "SHIFT + Escape", hl.dsp.exec_cmd("hyprshutdown"), {
    description = "Exit Hyprland gracefully with hyprshutdown (requires hyprshutdown package)",
})

-- Wlogout Menu
hl.bind(mainMod .. " + " .. "Escape", hl.dsp.exec_cmd("wlogout"), {
    description = "Wlogout Menu",
})

-- Lock screen
local lock_cmd = "pidof hyprlock || hyprlock"
hl.bind(mainMod .. " + " .. "SHIFT + L", hl.dsp.exec_cmd(lock_cmd), {
    description = "Lock screen",
})

-- Hyprland Control
-- --------------------------------------------------------------------------------------------------------------------------------------

local script_dir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Keybind reference
hl.bind(mainMod .. " + " .. "slash", hl.dsp.exec_cmd(script_dir .. "/KeybindsReference.sh"), {
    description = "Keybind reference",
})

hl.bind(mainMod .. " + " .. "SHIFT + slash", hl.dsp.exec_cmd(script_dir .. "/KeybindsReference.sh --tui"), {
    description = "Keybind reference (TUI)",
})

-- Close active window
hl.bind(mainMod .. " + " .. "Q", hl.dsp.window.close(), {
    description = "Close active window",
})

-- Kill active window
hl.bind(mainMod .. " + " .. "SHIFT + Q", kill, {
    description = "Kill active window",
})

-- Refresh
-- TODO: Migrate to native lua and hyprland if a better solution is available
hl.bind(mainMod .. " + " .. "R", hl.dsp.exec_cmd(script_dir .. "/Refresh.sh"), {
    description = "Refresh",
})

-- Toggle Floating Window
hl.bind(
    mainMod .. " + " .. "F",
    hl.dsp.window.float({
        action = "toggle",
    }),
    {
        description = "Toggle Floating Window",
    }
)

-- Toggle Fullscreen
hl.bind(
    mainMod .. " + " .. "SHIFT + F",
    hl.dsp.window.fullscreen({
        action = "toggle",
    }),
    {
        description = "Toggle Fullscreen",
    }
)

-- Resize properties
local resize_properties = {
    left = {
        x = -20,
        y = 0,
    },
    right = {
        x = 20,
        y = 0,
    },
    up = {
        x = 0,
        y = -20,
    },
    down = {
        x = 0,
        y = 20,
    },
}

-- Resize active window
for direction, properties in pairs(resize_properties) do
    hl.bind(mainMod .. " + " .. "SHIFT + " .. direction,
        hl.dsp.window.resize({ x = properties.x, y = properties.y, relative = true }), {
            repeating = true,
            description = "Resize active window " .. "(" .. direction .. ")",
        })
end

-- Move properties
local move_properties = {
    left = {
        action = "l",
        move_bind_key = "H",
        focus_bind_key = "CTRL + H",
    },
    right = {
        action = "r",
        move_bind_key = "L",
        focus_bind_key = "CTRL + L",
    },
    up = {
        action = "u",
        move_bind_key = "K",
        focus_bind_key = "CTRL + K",
    },
    down = {
        action = "d",
        move_bind_key = "J",
        focus_bind_key = "CTRL + J",
    },
}

for move_direction, properties in pairs(move_properties) do
    -- Swap active window
    hl.bind(mainMod .. " + " .. properties.move_bind_key, hl.dsp.window.swap({ direction = properties.action }), {
        description = "Swap active window " .. "(" .. move_direction .. ")",
    })

    -- Move focus
    hl.bind(mainMod .. " + " .. properties.focus_bind_key, hl.dsp.focus({ direction = properties.action }), {
        description = "Move focus " .. "(" .. move_direction .. ")",
    })
end

-- Cycle through windows
hl.bind("ALT + TAB", hl.dsp.window.cycle_next(), {
    repeating = true,
    description = "Cycle through windows",
})

-- Toggle active window to group
hl.bind(mainMod .. " + " .. "G", hl.dsp.group.toggle(), {
    description = "Toggle active window to group",
})

-- Cycle through windows in a group
hl.bind(mainMod .. " + " .. "CTRL + TAB", hl.dsp.group.next(), {
    repeating = true,
    description = "Cycle through windows in a group",
})

-- Drag window
hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), {
    mouse = true,
    description = "Drag window",
})

-- Dwindle layout specific keybinds
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Toggle pseudotile
hl.bind(
    mainMod .. " + " .. "P",
    hl.dsp.window.pseudo({
        action = "toggle",
    }),
    {
        description = "Toggle pseudotile",
    }
)

-- Toggle split
hl.bind(mainMod .. " + " .. "I", hl.dsp.layout("togglesplit"), {
    description = "Toggle split",
})
