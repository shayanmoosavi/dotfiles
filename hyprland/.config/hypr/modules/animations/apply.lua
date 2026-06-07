-- Module to apply animations
-- ==============================================================================================================================================

-- Importing declarative specs
local decl_animations = "modules.animations.declarative"
local curves = require(decl_animations .. ".specs").Curves
local animations = require(decl_animations .. ".specs").Animations

-- Internal helpers
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Define the curves so hyprland knows the curve name
local function define_curves()
    for name, specs in pairs(curves) do
        hl.curve(name, specs)
    end
end

-- Apply the animation
local function apply_animation(specs)
    local leaf = specs.leaf
    local enabled = specs.enabled
    if not enabled then return end

    local speed = specs.speed
    local style = specs.style
    local name = specs.name
    local curve_type = specs.curve_type

    -- The table structure is different for each curve style
    if curve_type == "spring" then
        local anim_specs = {
            leaf = leaf,
            enabled = true,
            speed = speed,
            spring = name,
            style = style
        }
        hl.animation(anim_specs)
    elseif curve_type == "bezier" then
        local anim_specs = {
            leaf = leaf,
            enabled = true,
            speed = speed,
            bezier = name,
            style = style
        }
        hl.animation(anim_specs)
    end
end

-- Applying the animations
-- --------------------------------------------------------------------------------------------------------------------------------------

-- Defining the curves
define_curves()

-- Apply the animations
for _, specs in pairs(animations) do
    apply_animation(specs)
end
