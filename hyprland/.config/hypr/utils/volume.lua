-- Volume Control Module for Hyprland
-- ==============================================================================

local M = {}

-- Importing common helpers
local exec = require("utils.common").exec
local play_sound = require("utils.common").play_sound
local safe_exec = require("utils.common").safe_exec

local desktop_sound_dir = "/usr/share/sounds/freedesktop"
local vol_change_sound = desktop_sound_dir .. "/stereo/audio-volume-change.oga"

-- Internal helpers
-- ----------------------------------------------------------------------

-- Get the name of the current default PulseAudio/PipeWire sink.
local function default_sink()
    return exec("pactl get-default-sink")
end

-- Return current volume as an integer (0–100+).
local function get_volume()
    local out = exec("pactl get-sink-volume " .. default_sink())
    -- Pattern matches the first percentage value in the output,
    -- e.g. "Volume: front-left: 65536 / 100% / 0.00 dB, ..."
    return tonumber(out:match("(%d+)%%")) or 0
end

-- Return true if the default sink is currently muted.
local function is_muted()
    local out = exec("pactl get-sink-mute " .. default_sink())
    return out:find("yes") ~= nil
end

-- Pick the right icon name based on volume level.
local function volume_icon(volume)
    if volume > 60 then
        return "audio-volume-high"
    elseif volume > 30 then
        return "audio-volume-medium"
    else
        return "audio-volume-low"
    end
end

-- Send a libnotify desktop notification with the current volume state.
local function notify(volume, muted)
    local icon, hint, title

    if muted then
        icon  = "audio-volume-muted"
        hint  = "int:value:0"
        title = "Volume Muted"
    else
        icon  = volume_icon(volume)
        hint  = "int:value:" .. volume
        title = string.format("Volume: %d%%", volume)
    end

    -- The x-canonical-private-synchronous hint makes notification daemons
    -- (like dunst) replace the previous volume notification instead of
    -- stacking them.
    safe_exec(string.format(
        'notify-send -t 2000'
        .. ' -h string:x-canonical-private-synchronous:volume'
        .. ' -h %s "%s" "" -i "%s"',
        hint, title, icon
    ))
end

-- Public API
-- ----------------------------------------------------------------------

function M.up()
    os.execute("pactl set-sink-volume @DEFAULT_SINK@ +5%")

    local vol = get_volume()
    if vol > 100 then
        os.execute("pactl set-sink-volume @DEFAULT_SINK@ 100%")
        vol = 100
    end

    -- Always unmute on a volume-up action so the user gets audio feedback.
    os.execute("pactl set-sink-mute @DEFAULT_SINK@ 0")

    notify(vol, false)
    play_sound(vol_change_sound)
end

function M.down()
    os.execute("pactl set-sink-volume @DEFAULT_SINK@ -5%")

    -- Mirror the up() behaviour: unmute so the user hears the change.
    os.execute("pactl set-sink-mute @DEFAULT_SINK@ 0")

    local vol = get_volume()
    notify(vol, false)
    play_sound(vol_change_sound)
end

function M.mute()
    os.execute("pactl set-sink-mute @DEFAULT_SINK@ toggle")

    local vol   = get_volume()
    local muted = is_muted()
    notify(vol, muted)
end

return M
