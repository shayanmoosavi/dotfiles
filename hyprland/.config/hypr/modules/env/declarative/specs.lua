-- Declarative specification for environment variables
-- ==============================================================================================================================================

-- Importing environment variable specs
local decl_env = "modules.env.declarative"
local toolkit_specs = require(decl_env .. ".toolkit_backend")
local xdg_specs = require(decl_env .. ".xdg")
local qt_specs = require(decl_env .. ".qt")
local nvidia_specs = require(decl_env .. ".nvidia")
local misc_specs = require(decl_env .. ".misc")

local specs = {
    toolkit_specs,
    xdg_specs,
    qt_specs,
    nvidia_specs,
    misc_specs,
}

return specs
