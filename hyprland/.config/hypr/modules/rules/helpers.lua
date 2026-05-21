-- Helper functions for setting window and layer rules
-- ==============================================================================================================================================


return {
    -- Tags helpers
    -- --------------------------------------------------------------------------------------------------------------------------------------

    -- Set 'browser' tags and 'chromium'/'firefox' tags
    Tag_browser_type = function()
        local browser_window_classes = {
            chromium = "^(brave-browser|vivaldi-stable)$",
            firefox = "^([Ff]irefox|[Ff]irefox-bin|floorp|zen)$"
        }

        for engine, pattern in pairs(browser_window_classes) do
            hl.window_rule({
                name = "tag-browser-type-" .. engine,
                match = {
                    class = pattern
                },
                tag = "+browser"
            })
            if engine == "chromium" then
                hl.window_rule({
                    name = "tag-chromium",
                    match = {
                        class = pattern
                    },
                    tag = "+chromium"
                })
            else
                hl.window_rule({
                    name = "tag-firefox",
                    match = {
                        class = pattern
                    },
                    tag = "+firefox"
                })
            end
        end
    end,

    -- Tag 'games' and 'gamelauncher' windows
    Tag_games = function()
        -- Gamescope and Steam app windows
        hl.window_rule({
            name = "tag-games",
            match = {
                class = "^(gamescope|steam_app_\\d+)$"
            },
            tag = "+games"
        })

        -- Game launcher windows
        hl.window_rule({
            name = "tag-gamelauncher",
            match = {
                class = "^([Ss]team|net.lutris.Lutris)$"
            },
            tag = "+gamelauncher"
        })
    end,

    -- Tag 'settings' for related apps
    Tag_settings = function()
        local settings_window_classes = {
            kde_settings = "kdesystemsettings",
            network_and_bluetooth = "^(nm-applet|nm-connection-editor|blueman-manager)$",
            audio = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$",
            theme_and_display = "^(qt5ct|qt6ct|nwg-displays|nwg-look|kvantummanager)$",
            desktop_portal = "xdg-desktop-portal-gtk",
        }

        for category, pattern in pairs(settings_window_classes) do
            hl.window_rule({
                name = "tag-settings-" .. category,
                match = {
                    class = pattern
                },
                tag = "+settings"
            })
        end
    end,

    -- Window rules helpers
    -- --------------------------------------------------------------------------------------------------------------------------------------

    -- Float and center system monitor
    Float_center_system_monitor = function()
        hl.window_rule({
            name = "float-center-system-monitor",
            match = {
                title = "^(System Monitor)$"
            },
            float = true,
            center = true,
            size = {
                "monitor_w * 0.6",
                "monitor_h * 0.6"
            }
        })

        hl.window_rule({
            name = "float-center-missioncenter",
            match = {
                class = "^(io.missioncenter.MissionCenter)$"
            },
            float = true,
            center = true,
            size = {
                "monitor_w * 0.6",
                "monitor_h * 0.6"
            }
        })
    end,

    -- Float and center setting dialogues
    Float_center_settings = function()
        hl.window_rule({
            name = "float-center-settings",
            match = {
                tag = "settings*"
            },
            float = true,
            center = true,
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.7"
            }
        })
    end,

    -- Float and center image viewer (replace with your preferred image viewer)
    Float_center_image_viewer = function()
        hl.window_rule({
            name = "float-center-image-viewer",
            match = {
                class = "^(org.gnome.Loupe|org.kde.gwenview)$"
            },
            float = true,
            center = true,
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.7"
            }
        })
    end,

    -- Float and center clipboard manager
    Float_center_clip_manager = function()
        hl.window_rule({
            name = "float-center-clip-mgr",
            match = {
                class = "clipse"
            },
            float = true,
            center = true,
            stay_focused = true,
            size = {
                622,
                652
            }
        })
    end,

    -- Float and center file manager dialogues (replace with your preferred file manager)
    Float_center_file_manager_dialog = function()
        hl.window_rule({
            name = "float-center-file-manager-dialog",
            match = {
                class = "[Tt]hunar",
                title = "negative:(.*[Tt]hunar.*)"
            },
            float = true,
            center = true
        })
    end,

    -- Float and center firefox-based browsers dialogues (bookmarks, history, etc.)
    Float_center_firefox_dialog = function()
        hl.window_rule({
            name = "float-center-firefox-dialog",
            match = {
                tag = "firefox*",
                title = "Library"
            },
            float = true,
            center = true
        })
    end,

    -- Float and center authentication dialogues (i.e., sudo password prompts)
    Float_center_auth_dialog = function()
        hl.window_rule({
            name = "float-center-auth-dialog",
            match = {
                class =
                "^(hyprpolkitagent|org.kde.polkit-kde-authentication-agent-1|org.gnome.polkit-gnome-authentication-agent-1)$",
                title = "Authentication Required"
            },
            float = true,
            center = true
        })
    end,

    -- Float and center file dialogues (e.g., save as, open files)
    Float_center_file_dialog = function()
        hl.window_rule({
            name = "float-center-save-as",
            match = {
                title = "Save As"
            },
            float = true,
            center = true,
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.6"
            }
        })
        hl.window_rule({
            name = "float-center-open-files",
            match = {
                initial_title = "Open Files"
            },
            float = true,
            center = true,
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.6"
            }
        })
    end,

    -- Float and center archive manager dialogues (replace with your preferred archive manager)
    Float_center_archive_manager = function()
        hl.window_rule({
            name = "float-center-archive-mgr",
            match = {
                class = "org.kde.ark|xarchiver"
            }
        })
    end,

    -- Layer rules helpers
    -- --------------------------------------------------------------------------------------------------------------------------------------

    -- Blur Rofi
    Blur_rofi = function()
        hl.layer_rule({
            name = "blur-rofi",
            match = {
                namespace = "rofi"
            },
            blur = true,
            xray = true,
            dim_around = true,
            ignore_alpha = 0
        })
    end,

    -- Blur Notifications
    Blur_notifications = function()
        hl.layer_rule({
            name = "blur-notifications",
            match = {
                namespace = "notifications"
            },
            blur = true
        })
        hl.layer_rule({
            name = "blur-swaync",
            match = {
                namespace = "^(swaync-control-center|swaync-notification-window)$"
            },
            blur = true,
            ignore_alpha = 0.5
        })
    end,

    -- Blur Wlogout
    Blur_wlogout = function()
        hl.layer_rule({
            name = "blur-wlogout",
            match = {
                namespace = "logout_dialog"
            },
            blur = true,
            ignore_alpha = 0.2
        })
    end

}
