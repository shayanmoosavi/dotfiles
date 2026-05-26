-- Window Decorations
-- ==============================================================================================================================================
-- Based on JaKooLit dotfiles
-- https://github.com/JaKooLit

-- Importing matugen colors
local matugen = require("colors.matugen")

hl.config({

    -- General Window Settings
    general = {
        border_size = 3,
        gaps_in = 2,
        gaps_out = 4,

        resize_on_border = true,

        col = {
            active_border = {
                colors = {
                    matugen.primary_container,
                    matugen.tertiary_container,
                },
                angle = 180
            },
            inactive_border = matugen.secondary_container,
        },

        -- Snapping settings for floating windows
        snap = {
            enabled = true,
            respect_gaps = true,
        },
    },

    -- Window Group Settings
    group = {
        col = {
            border_active = matugen.primary_container,
            border_inactive = matugen.secondary_container,
        },
        groupbar = {
            font_size = 10,
            font_weight_active = "semibold",
            font_weight_inactive = "semilight",
            text_color = matugen.on_surface,
            col = {
                active = matugen.tertiary_fixed,
                inactive = matugen.surface_dim
            },
            gaps_out = 8,
            text_offset = 8
        },
    },

    -- Dwindle layout settings
    dwindle = {
        smart_split = true,
    },

    -- Window Decoration Settings
    decoration = {
        -- Rounding of corners
        rounding = 16,

        -- Window opacity
        active_opacity = 0.8,
        inactive_opacity = 0.75,
        fullscreen_opacity = 1.0,

        -- Window dimming
        dim_inactive = true,
        dim_strength = 0.3,
        dim_around = 0.6,
        dim_special = 0.8,

        -- Window blur
        blur = {
            enabled = true,
            size = 10,
            passes = 3,
            noise = 0.03,
            contrast = 1.1,
            ignore_opacity = true,
            new_optimizations = true,
            popups = true,
            special = true,
        },

        -- Window border shadows
        shadow = {
            enabled = true,
            range = 3,
            render_power = 3,

            color = matugen.outline,
            color_inactive = matugen.outline_variant,
        },
    },
})
