-- Declarative specification for startup applications in Hyprland
-- ==============================================================================================================================================

return {
    -- Wayland Environment
    -- Imports display server variables so systemd services and portals can see them. They need to be executed before everything else.
    Wayland = {
        {
            description = "Updating activation environment variables for Wayland",
            exec = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        },
        {
            description = "Importing environment variables for Wayland",
            exec = "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        }
    },

    -- Authentication Agent
    -- (edit for your polkit of choice, e.g., GNOME)
    -- KDE polkit agent handles privilege escalation prompts (e.g. mounting drives).
    -- pam_kwallet unlocks the KWallet keyring on login.
    Polkit = {
        {
            description = "Starting KDE Polkit authentication agent",
            exec = "/usr/lib/polkit-kde-authentication-agent-1",
        },
        {
            description = "Starting KDE PAM",
            exec = "/usr/lib/pam_kwallet_init",
        }
    },

    -- Desktop
    Desktop = {
        {
            description = "Setting cursor theme",
            exec = "hyprctl setcursor XCursor-Pro-Hyprcursor-Dark 24",
        }
    },

    -- Applications
    Apps = {
        {
            description = "Starting wallpaper daemon",
            exec = "awww-daemon",
        },
        {
            description = "Starting notification daemon",
            exec = "swaync",
        },
        {
            description = "Starting network manager",
            exec = "nm-applet --indicator",
        },
        {
            description = "Starting bluetooth manager",
            exec = "blueman-applet",
        },
        {
            description = "Starting clipboard manager",
            exec = "clipse --listen",
        },
        {
            description = "Starting hypridle",
            exec = "hypridle",
        },
        {
            description = "Starting status bar",
            exec = "waybar",
        },
        {
            description = "Starting hyprsunset",
            exec = "hyprsunset",
        }
    }
}
