-- Custom kill program helper function
-- ==============================================================================

-- Import play sound function
local play_sound = require("utils.common").play_sound

-- DOOM shotgun sound path
local hypr_root = os.getenv("HOME") .. "/.config/hypr"
local doom_shotgun = hypr_root .. "/sounds/SHOTGUN16.WAV"

return {
    kill = function()
        -- Kills the active window
        hl.dispatch(hl.dsp.window.kill())

        -- Plays the DOOM shotgun sound
        play_sound(doom_shotgun)

        os.execute('notify-send -t 3000 "󰓾  Kill Program" "Target Neutralized" &')
    end,
}
