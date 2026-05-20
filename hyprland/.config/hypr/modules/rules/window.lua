-- Window rules
-- ==============================================================================================================================================

-- Import helpers
local helpers = require("modules.rules.helpers")

-- Tags
-- --------------------------------------------------------------------------------------------------------------------------------------
-- Tagging certain grouped windows for easier window rules

helpers.Tag_browser_type()
helpers.Tag_games()
helpers.Tag_settings()

-- Social Media
hl.window_rule({
    name = "tag-social-media",
    match = {
        class = "^(org.telegram.desktop|discord)$",
    },
    tag = "+social",
})

-- Terminal
hl.window_rule({
    name = "tag-terminal",
    match = {
        class = "^(alacritty|kitty|com.mitchellh.ghostty)$",
    },
    tag = "+terminal",
})

-- Multimedia
hl.window_rule({
    name = "tag-multimedia",
    match = {
        class = "^(vlc|mpv|spotify|spotify-client)$",
    },
    tag = "+multimedia",
})

-- IDE
hl.window_rule({
    name = "tag-ide",
    match = {
        class = "^(jetbrains-.*|code|code-oss|codium|dev.zed.Zed)$",
    },
    tag = "+ide",
})

-- Window rules
-- --------------------------------------------------------------------------------------------------------------------------------------

-- No transparency and blur for multimedia
hl.window_rule({
    name = "no-transparency-multimedia",
    match = {
        tag = "multimedia*",
    },
    no_blur = true,
    opacity = "1.0",
})

-- No blur for games
hl.window_rule({
    name = "no-blur-games",
    match = {
        tag = "games*",
    },
    no_blur = true,
    fullscreen = true,
})

-- Prevent idle for fullscreen windows
hl.window_rule({
    name = "no-idle-fullscreen",
    match = {
        fullscreen = true,
    },
    idle_inhibit = "fullscreen",
})

-- Float and center keybinds reference
hl.window_rule({
    name = "float-center-key-ref",
    match = {
        title = "Keybinds Reference",
    },
    float = true,
    center = true,
    size = {
        "monitor_h * 0.7",
        "monitor_w * 0.7",
    },
})

-- Float and center SDDM wallpaper updater dialogue
hl.window_rule({
    name = "float-center-sddm-wallpaper",
    match = {
        title = "Update SDDM Wallpaper",
    },
    float = true,
    center = true,
    size = {
        "monitor_h * 0.6",
        "monitor_w * 0.6",
    },
})

-- Float and center waypaper
hl.window_rule({
    name = "float-center-waypaper",
    match = {
        class = "waypaper",
    },
    float = true,
    center = true,
})

-- Float and center steam dialogues
hl.window_rule({
    name = "float-center-steam-dialogues",
    match = {
        class = "^([Ss]team)$",
        title = "negative:^([Ss]team)$",
    },
    float = true,
    center = true,
})

-- Picture-in-picture
hl.window_rule({
    name = "picture-in-picture",
    match = {
        title = "Picture-in-Picture",
    },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
})

-- Float and center calculator
hl.window_rule({
    name = "float-center-calculator",
    match = {
        title = "^(org.kde.kalk|org.kde.kcalc)$",
    },
    float = true,
    center = true,
})

helpers.Float_center_archive_manager()
helpers.Float_center_auth_dialog()
helpers.Float_center_clip_manager()
helpers.Float_center_file_dialog()
helpers.Float_center_file_manager_dialog()
helpers.Float_center_firefox_dialog()
helpers.Float_center_image_viewer()
helpers.Float_center_settings()
helpers.Float_center_system_monitor()

-- Move to workspace window rules
local workspace_categories = {
    browser = 1,
    social = 3,
    ide = 4,
    gamelauncher = 5,
    games = 6,
}

for category, workspace in pairs(workspace_categories) do
    hl.window_rule({
        name = "move-" .. category .. "-to-" .. workspace,
        match = {
            tag = category .. "*",
        },
        workspace = workspace,
    })
end
