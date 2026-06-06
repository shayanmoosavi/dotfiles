-- Window Decorations
-- ==============================================================================================================================================
-- Based on JaKooLit dotfiles
-- https://github.com/JaKooLit

-- Importing declarative specs
local decl_settings = "modules.settings.declarative"
local decorations = require(decl_settings .. ".decorations")

hl.config(decorations)
