-- Declarative specification of other settings
-- ==============================================================================================================================================

local other = {
    misc = {
        disable_hyprland_logo = true
    },

    binds = {
        allow_workspace_cycles = true,
        workspace_back_and_forth = true,
        drag_threshold = 10
    },

    xwayland = {
        force_zero_scaling = true
    },

    render = {
        -- Auto; Attempts to reduce lag when there is only one fullscreen application on a screen (e.g. game).
        direct_scanout = 2,
        new_render_scheduling = true
    },

    cursor = {
        warp_on_change_workspace = 1
    },

    -- For HDR monitors
    --[[Some clients expect monitor to be in HDR mode prior to the client start. This breaks auto HDR activation and
    can cause whitescreen and flickering. Use prefer_hdr to fix it]]
    -- https://wiki.hypr.land/Configuring/Basics/Variables/#quirks
    quirks = {
        -- Gamescope only
        prefer_hdr = 2
    }
}

return other
