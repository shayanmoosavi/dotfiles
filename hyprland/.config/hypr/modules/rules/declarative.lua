-- Declarative window rule specs
-- ==============================================================================================================================================

return {
    -- Window rule specs for tags
    -- -------------------------------------------------------------------------------------------------------------------
    Tags = {
        -- Social Media
        social = {
            name = "tag-social-media",
            match = {
                class = "^(org.telegram.desktop|discord)$",
            },
            tag = "+social"
        },
        -- Terminal
        terminal = {
            name = "tag-terminal",
            match = {
                class = "^(alacritty|kitty|com.mitchellh.ghostty)$",
            },
            tag = "+terminal"
        },
        -- Multimedia
        multimedia = {
            name = "tag-multimedia",
            match = {
                class = "^(vlc|mpv|spotify|spotify-client)$",
            },
            tag = "+multimedia"
        },
        -- IDE
        ide = {
            name = "tag-ide",
            match = {
                class = "^(jetbrains-.*|code|code-oss|codium|dev.zed.Zed)$",
            },
            tag = "+ide"
        }
    }
}
