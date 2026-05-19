-- Special Keys Keybinds
-- ==============================================================================================================================================

-- Scripts directory
local script_dir = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Volume Control
-- --------------------------------------------------------------------------------------------------------------------------------------

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(script_dir .. "/Volume.sh up"), {
    repeating = true,
    description = "Volume up"
})

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(script_dir .. "/Volume.sh down"), {
    repeating = true,
    description = "Volume down"
})

hl.bind("XF86AudioMute", hl.dsp.exec_cmd(script_dir .. "/Volume.sh mute"), {
    description = "Mute volume"
})

-- Brightness Control
-- --------------------------------------------------------------------------------------------------------------------------------------

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(script_dir .. "/Brightness.sh --inc 5"), {
    description = "Brightness up"
})

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(script_dir .. "/Brightness.sh --dec 5"), {
    description = "Brightness down"
})
