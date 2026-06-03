-- Declarative window rules for floating and centering windows
-- ==============================================================================================================================================

local float_center = {
    -- System monitor
    {
        name = "float-center-system-monitor",
        match = {
            title = "^(System Monitor)$"
        },
        size = {
            "monitor_w * 0.6",
            "monitor_h * 0.6"
        }
    },
    {
        name = "float-center-missioncenter",
        match = {
            class = "^(io.missioncenter.MissionCenter)$"
        },
        size = {
            "monitor_w * 0.6",
            "monitor_h * 0.6"
        }
    },

    {
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
    {
        name = "float-center-image-viewer",
        match = {
            class = "^(org.gnome.Loupe|org.kde.gwenview)$"
        },
        size = {
            "monitor_w * 0.7",
            "monitor_h * 0.7"
        }
    },

    -- Clipboard manager (replace with your preferred clipboard manager)
    {
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
    {
        name = "float-center-file-manager-dialogs",
        match = {
            class = "[Tt]hunar",
            title = "negative:(.*[Tt]hunar.*)"
        }
    },

    -- Firefox-based browsers dialogues (bookmarks, history, etc.)
    {
        name = "float-center-firefox-dialogs",
        match = {
            tag = "firefox*",
            title = "Library"
        }
    },

    -- Authentication dialogues (i.e., sudo password prompts)
    {
        name = "float-center-auth-dialog",
        match = {
            class =
            "^(hyprpolkitagent|org.kde.polkit-kde-authentication-agent-1|org.gnome.polkit-gnome-authentication-agent-1)$",
            title = "Authentication Required"
        }
    },

    -- File dialogues (e.g., save as, open files)
    {
        name = "float-center-save-as",
        match = {
            title = "Save As"
        },
        size = {
            "monitor_w * 0.7",
            "monitor_h * 0.6"
        }
    },
    {
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
    {
        name = "float-center-archive-mgr",
        match = {
            class = "org.kde.ark|xarchiver"
        }
    },

    -- Keybinds reference
    {
        name = "float-center-key-ref",
        match = {
            title = "Keybinds Reference",
        },
        size = {
            "monitor_w * 0.7",
            "monitor_h * 0.7",
        }
    },

    -- Custom SDDM wallpaper updater dialogue (scripts)
    {
        name = "float-center-sddm-wallpaper-updater",
        match = {
            title = "Update SDDM Wallpaper",
        },
        size = {
            "monitor_w * 0.6",
            "monitor_h * 0.6",
        }
    },

    -- Custom wallpaper picker (scripts)
    {
        name = "float-center-wallpaper-picker",
        match = {
            title = "Wallpaper Picker",
        },
        size = {
            "monitor_w * 0.4",
            "monitor_h * 0.4",
        }
    },

    -- Waypaper
    {
        name = "float-center-waypaper",
        match = {
            class = "waypaper",
        }
    },

    -- Steam dialogues
    {
        name = "float-center-steam-dialogs",
        match = {
            class = "^([Ss]team)$",
            title = "negative:^([Ss]team)$",
        }
    },

    -- Calculator (Add more as needed)
    {
        name = "float-center-calculator",
        match = {
            class = "^(org.kde.kalk|org.kde.kcalc)$",
        }
    }
}

return float_center
