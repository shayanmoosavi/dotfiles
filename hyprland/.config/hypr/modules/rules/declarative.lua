-- Declarative window rule/layer rule specs
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
    },

    -- Enable blur for certain layers
    -- -------------------------------------------------------------------------------------------------------------------
    Blur = {

        -- Rofi
        rofi = {
            name = "blur-rofi",
            match = {
                namespace = "rofi"
            },
            blur = true,
            xray = true,
            dim_around = true,
            ignore_alpha = 0
        },

        -- Notifications
        notifications = {
            name = "blur-notifications",
            match = {
                namespace = "notifications"
            },
            blur = true
        },

        -- Notification Center (replace with your preferred notification center)
        notification_center = {
            name = "blur-notification-center",
            match = {
                namespace = "^(swaync-control-center|swaync-notification-window)$"
            },
            blur = true,
            ignore_alpha = 0.5
        },

        -- Logout dialogue (replace with your preferred logout dialogue)
        logout_dialog = {
            name = "blur-logout-dialog",
            match = {
                namespace = "logout_dialog"
            },
            blur = true,
            ignore_alpha = 0.2
        },
    },

    -- Disable blur for certain windows
    -- -------------------------------------------------------------------------------------------------------------------
    NoBlur = {
        -- No transparency and blur for multimedia
        multimedia = {
            name = "no-transparency-multimedia",
            match = {
                tag = "multimedia*",
            },
            no_blur = true,
            opacity = "1.0 override"
        },

        -- No blur for games
        games = {
            name = "no-blur-games",
            match = {
                tag = "games*",
            },
            no_blur = true,
            fullscreen = true,
        }
    },

    -- Prevent idle for fullscreen windows
    -- -------------------------------------------------------------------------------------------------------------------
    NoIdle = {
        fullscreen = {
            name = "no-idle-fullscreen",
            match = {
                fullscreen = true,
            },
            idle_inhibit = "fullscreen",
        }
    },

    -- Picture-in-Picture
    -- -------------------------------------------------------------------------------------------------------------------
    PiP = {
        pip = {
            name = "picture-in-picture",
            match = {
                title = "Picture-in-Picture",
            },
            float = true,
            pin = true,
            keep_aspect_ratio = true
        }
    },

    -- Floating and centering windows
    -- -------------------------------------------------------------------------------------------------------------------
    FloatCenter = {

        -- System monitor
        system_monitor = {
            name = "float-center-system-monitor",
            match = {
                title = "^(System Monitor)$"
            },
            size = {
                "monitor_w * 0.6",
                "monitor_h * 0.6"
            }
        },
        mission_center = {
            name = "float-center-missioncenter",
            match = {
                class = "^(io.missioncenter.MissionCenter)$"
            },
            size = {
                "monitor_w * 0.6",
                "monitor_h * 0.6"
            }
        },

        -- Setting dialogues
        settings = {
            name = "float-center-settings",
            match = {
                tag = "settings*"
            },
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.7"
            }
        },

        -- Image viewer (replace with your preferred image viewer)
        image_viewer = {
            name = "float-center-image-viewer",
            match = {
                class = "^(org.gnome.Loupe|org.kde.gwenview)$"
            },
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.7"
            }
        },

        -- Clipboard manager
        clipboard_manager = {
            name = "float-center-clip-mgr",
            match = {
                class = "clipse"
            },
            stay_focused = true,
            size = {
                622,
                652
            }
        },

        -- File manager dialogues (replace with your preferred file manager)
        file_manager = {
            name = "float-center-file-manager-dialogs",
            match = {
                class = "[Tt]hunar",
                title = "negative:(.*[Tt]hunar.*)"
            }
        },

        -- Firefox-based browsers dialogues (bookmarks, history, etc.)
        firefox_dialogs = {
            name = "float-center-firefox-dialogs",
            match = {
                tag = "firefox*",
                title = "Library"
            }
        },

        -- Authentication dialogues (i.e., sudo password prompts)
        auth_dialogs = {
            name = "float-center-auth-dialog",
            match = {
                class =
                "^(hyprpolkitagent|org.kde.polkit-kde-authentication-agent-1|org.gnome.polkit-gnome-authentication-agent-1)$",
                title = "Authentication Required"
            }
        },

        -- File dialogues (e.g., save as, open files)
        save_as_dialogs = {
            name = "float-center-save-as",
            match = {
                title = "Save As"
            },
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.6"
            }
        },
        open_file_dialogs = {
            name = "float-center-open-files",
            match = {
                initial_title = "Open Files"
            },
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.6"
            }
        },

        -- Archive manager dialogues (replace with your preferred archive manager)
        archive_manager_dialogs = {
            name = "float-center-archive-mgr",
            match = {
                class = "org.kde.ark|xarchiver"
            }
        },

        -- Keybinds reference
        keybind_ref = {
            name = "float-center-key-ref",
            match = {
                title = "Keybinds Reference",
            },
            size = {
                "monitor_w * 0.7",
                "monitor_h * 0.7",
            }
        },

        -- SDDM wallpaper updater dialogue
        sddm_wallpaper_updater = {
            name = "float-center-sddm-wallpaper-updater",
            match = {
                title = "Update SDDM Wallpaper",
            },
            size = {
                "monitor_w * 0.6",
                "monitor_h * 0.6",
            }
        },

        -- Waypaper
        waypaper = {
            name = "float-center-waypaper",
            match = {
                class = "waypaper",
            }
        },

        -- Steam dialogues
        steam_dialogs = {
            name = "float-center-steam-dialogs",
            match = {
                class = "^([Ss]team)$",
                title = "negative:^([Ss]team)$",
            }
        },

        -- Calculator
        calculator = {
            name = "float-center-calculator",
            match = {
                class = "^(org.kde.kalk|org.kde.kcalc)$",
            }
        }
    }
}
