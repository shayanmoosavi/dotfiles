-- Declarative specification for NVidia environment variables
-- ==============================================================================================================================================
-- Copied from Hyprland wiki
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

local nvidia_specs = {
    {
        variable = "GBM_BACKEND",
        value = "nvidia-drm"
    },
    {
        variable = "__GLX_VENDOR_LIBRARY_NAME",
        value = "nvidia"
    },

    -- Hardware acceleration on Nvidia GPUs
    {
        variable = "LIBVA_DRIVER_NAME",
        value = "nvidia"
    },
    {
        variable = "VDPAU_DRIVER",
        value = "nvidia"
    },
    {
        variable = "NVD_BACKEND",
        value = "direct"
    }
}

return nvidia_specs
