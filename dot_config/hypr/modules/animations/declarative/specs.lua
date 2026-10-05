-- Declarative specification for animations module
-- ==============================================================================================================================================

-- Importing declarative specs
local decl_animations = "modules.animations.declarative"
return {
    Curves = require(decl_animations .. ".curves"),
    Animations = require(decl_animations .. ".animations")
}
