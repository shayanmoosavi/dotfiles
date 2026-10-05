-- Custom kill program helper function
-- ==============================================================================

-- Import helpers
local play_sound = require("utils.common").play_sound
local safe_exec = require("utils.common").safe_exec

-- DOOM shotgun sound path
local hypr_root = os.getenv("HOME") .. "/.config/hypr"
local doom_shotgun = hypr_root .. "/sounds/SHOTGUN16.WAV"

return {
    kill = function()
        -- Kills the active window
        hl.dispatch(hl.dsp.window.kill())

        -- Plays the DOOM shotgun sound
        play_sound(doom_shotgun)

        safe_exec('notify-send -t 3000 -e "󰓾  Kill Program" "Target Neutralized"')
    end,
}
