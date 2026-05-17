-- Input & Gestures
-- ==============================================================================================================================================


-- Keyboard layouts and touchpad settings
hl.config({
    input = {
        kb_layout = "us, ir",
        kb_options = "grp:alt_space_toggle",

        natural_scroll = true,

        touchpad = {
            natural_scroll = true
        }
    }
})

-- Touchpad gestures
-- ---------------------------------------------------------------------

-- Swipe horizontal to switch workspaces
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Swipe up to close active window
hl.gesture({
    fingers = 3,
    direction = "up",
    action = "close"
})
