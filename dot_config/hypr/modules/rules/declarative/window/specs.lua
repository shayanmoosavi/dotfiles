-- Declarative specification for window rules
-- ==============================================================================================================================================

local decl_window = "modules.rules.declarative.window"

-- Importing declarative window rules
local window_specs = {
    Tags = require(decl_window .. ".tags"),
    NoBlur = require(decl_window .. ".noblur"),
    NoIdle = require(decl_window .. ".noidle"),
    PictureInPicture = require(decl_window .. ".picture_in_picture"),
    FloatCenter = require(decl_window .. ".float_center"),
    MoveToWorkspace = require(decl_window .. ".move_to_workspace"),
}

return window_specs
