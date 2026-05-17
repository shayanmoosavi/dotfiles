-- Animations
-- ==============================================================================================================================================


hl.config({
    animations = {
        enabled = true,
        workspace_wraparound = true
    }
})

for _, value in ipairs({ "windowsIn", "windowsOut" }) do
    hl.animation({
        leaf = value,
        enabled = true,
        speed = 4,
        bezier = "default",
        style = "popin"
    })
end

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 7,
    bezier = "default",
    style = "slidefade 70%"
})

hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 4,
    bezier = "default",
    style = "popin"
})
