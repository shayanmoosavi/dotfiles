-- Environment Variables
-- ==============================================================================================================================================
-- Copied from Hyprland wiki
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/


-- Toolkit backend variables
-- --------------------------------------------------------------------------------------------------------------------------------------

-- GTK: Use Wayland if available; if not, try X11 and then any other GDK backend.
hl.env("GDK_BACKEND", "wayland,x11,*")

-- Qt: Use Wayland if available, fall back to X11 if not.
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL cause compatibility issues
hl.env("SDL_VIDEODRIVER", "wayland")

-- Clutter package already has Wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
hl.env("CLUTTER_BACKEND", "wayland")


-- XDG Specifications
-- --------------------------------------------------------------------------------------------------------------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_MENU_PREFIX", "arch-")

-- Qt Variables
-- --------------------------------------------------------------------------------------------------------------------------------------

-- enables automatic scaling, based on the monitor's pixel density
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Tell Qt applications to use the Wayland backend, and fall back to X11 if Wayland is unavailable
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- Disables window decorations on Qt applications
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- Tells Qt based applications to pick your theme from qt5ct, use with Kvantum.
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

-- Nvidia
-- --------------------------------------------------------------------------------------------------------------------------------------

hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Hardware acceleration on Nvidia GPUs
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("VDPAU_DRIVER", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- Solving flickering in Electron / CEF apps
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
