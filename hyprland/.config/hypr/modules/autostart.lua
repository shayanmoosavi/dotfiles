-- Startup Applications
-- ==============================================================================================================================================


-- Starting necessary services and importing environment variables for Wayland
local function start_wayland()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end

-- Start KDE Polkit Agent (edit for your polkit of choice, e.g., GNOME)
local function start_kde_polkit_agent()
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("/usr/lib/pam_kwallet_init")
end


hl.on("hyprland.start", function()
    -- Pre-desktop initialization
    start_wayland()
    start_kde_polkit_agent()

    -- Hyprcursor theme
    hl.exec_cmd("hyprctl setcursor XCursor-Pro-Hyprcursor-Dark 24")

    -- Wallpaper
    hl.exec_cmd("awww-daemon")

    -- Notification Daemon
    hl.exec_cmd("swaync")

    -- Network & Bluetooth
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")

    -- Clipboard Manager
    hl.exec_cmd("clipse --listen")

    -- Hypridle
    hl.exec_cmd("hypridle")

    -- Waybar
    hl.exec_cmd("waybar")
end)
