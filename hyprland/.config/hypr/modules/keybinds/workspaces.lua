-- Hyprland Workspaces Keybinds
-- ==============================================================================================================================================

-- MainMod Key
local mainMod = require("modules.defaults").MainMod

-- Cycle workspaces on monitor
hl.bind(mainMod .. " + " .. "TAB", hl.dsp.focus({ workspace = "m+1" }), {
	description = "Cycle next workspace on monitor",
})
hl.bind(mainMod .. " + " .. "SHIFT + TAB", hl.dsp.focus({ workspace = "m-1" }), {
	description = "Cycle previous workspace on monitor",
})

-- Cycle open workspaces
hl.bind(mainMod .. " + " .. "period", hl.dsp.focus({ workspace = "e+1" }), {
	description = "Cycle next open workspace",
})
hl.bind(mainMod .. " + " .. "comma", hl.dsp.focus({ workspace = "e-1" }), {
	description = "Cycle previous open workspace",
})

-- Number keys key code mapping
local number_keys = {
	[1] = "code:10",
	[2] = "code:11",
	[3] = "code:12",
	[4] = "code:13",
	[5] = "code:14",
	[6] = "code:15",
	[7] = "code:16",
	[8] = "code:17",
	[9] = "code:18",
	[0] = "code:19",
}

for number, keycode in pairs(number_keys) do
	-- Switch to specified workspace with mainMod + [0-9]
	hl.bind(mainMod .. " + " .. keycode, hl.dsp.focus({ workspace = number }), {
		description = "Switch to workspace " .. number,
	})
	-- Move active window and follow to workspace with mainMod + SHIFT + [0-9]
	hl.bind(
		mainMod .. " + " .. "SHIFT + " .. keycode,
		hl.dsp.window.move({ workspace = number }),
		{ description = "Move active window to workspace " .. number }
	)
	-- Move active window to a workspace silently with mainMod + CTRL + [0-9]
	hl.bind(
		mainMod .. " + " .. "CTRL + " .. keycode,
		hl.dsp.window.move({
			workspace = number,
			follow = false,
		}),
		{ description = "Move active window to workspace " .. number .. " (silent)" }
	)
end

-- Move active window to next workspace
hl.bind(mainMod .. " + " .. "bracketright", hl.dsp.window.move({ workspace = "+1" }), {
	description = "Move active window to next workspace",
})

-- Move active window to previous workspace
hl.bind(mainMod .. " + " .. "bracketleft", hl.dsp.window.move({ workspace = "-1" }), {
	description = "Move active window to previous workspace",
})
