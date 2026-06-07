-- Animations
-- ==============================================================================================================================================


hl.config({
    animations = {
        enabled = true,
        workspace_wraparound = true
    }
})

hl.curve("windows_curve", { type = "spring", mass = 1, stiffness = 40, dampening = 8 })
hl.curve("workspace_curve", { type = "spring", mass = 1, stiffness = 30, dampening = 8 })
hl.curve("layer_curve", { type = "spring", mass = 1, stiffness = 60, dampening = 12 })

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 6,
    spring = "windows_curve",
    style = "popin"
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 6,
    spring = "workspace_curve",
    style = "slidefade 70%"
})

hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 6,
    spring = "layer_curve",
    style = "slide right"
})
