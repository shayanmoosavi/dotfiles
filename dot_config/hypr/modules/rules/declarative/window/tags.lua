-- Declarative window rules for setting window tags
-- ==============================================================================================================================================

-- Tagging certain grouped windows for easier window rules
local tags = {
    {
        name = "tag-social-media",
        match = {
            class = "^(org.telegram.desktop|discord)$",
        },
        tag = "+social"
    },
    {
        name = "tag-terminal",
        match = {
            class = "^(alacritty|kitty|com.mitchellh.ghostty)$",
        },
        tag = "+terminal"
    },
    {
        name = "tag-multimedia",
        match = {
            class = "^(vlc|mpv|spotify|spotify-client)$",
        },
        tag = "+multimedia"
    },
    {
        name = "tag-ide",
        match = {
            class = "^(jetbrains-.*|code|code-oss|codium|dev.zed.Zed)$",
        },
        tag = "+ide"
    }
}

return tags
