-- Declarative window rules for disabling blur and transparency
-- ==============================================================================================================================================

local noblur = {
    -- No transparency and blur for multimedia
    {
        name = "no-transparency-multimedia",
        match = {
            tag = "multimedia*",
        },
        no_blur = true,
        opacity = "1.0 override"
    },

    -- No blur for games
    {
        name = "no-blur-games",
        match = {
            tag = "games*",
        },
        no_blur = true,
        fullscreen = true,
    }
}

return noblur
