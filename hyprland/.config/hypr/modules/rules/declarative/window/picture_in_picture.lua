-- Declarative window rules for Picture-in-Picture mode
-- ==============================================================================================================================================

local pip = {
    {
        name = "picture-in-picture",
        match = {
            title = "Picture-in-Picture",
        },
        float = true,
        pin = true,
        keep_aspect_ratio = true
    }
}

return pip
