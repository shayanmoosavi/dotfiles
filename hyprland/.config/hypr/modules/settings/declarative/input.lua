-- Declarative specification of input settings
-- ==============================================================================================================================================

local input_settings = {
    input = {
        kb_layout = "us, ir",

        -- Toggle between keyboard layouts using Alt+Space
        kb_options = "grp:alt_space_toggle",

        natural_scroll = true,

        touchpad = {
            natural_scroll = true
        }
    }
}

return input_settings
