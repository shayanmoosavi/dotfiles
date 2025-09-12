-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- The filled in variant of the < symbol
-- local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

-- The filled in variant of the > symbol
-- local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

-- This is where you actually apply your config choices
config.term = "wezterm"
config.default_prog = { '/bin/zsh', '-i' }
config.color_scheme = "nord"
-- config.window_background_image = '/home/shayan/Pictures/662381-hd-arch-linux-wallpaper.png'
config.window_background_opacity = 0.85

config.window_background_image_hsb = {
	-- Darken the background image by reducing it to 1/3rd
	brightness = 1.0,

	-- You can adjust the hue by scaling its value.
	-- a multiplier of 1.0 leaves the value unchanged.
	hue = 1.0,

	-- You can adjust the saturation also.
	saturation = 1.25,
}

-- This function returns the suggested title for a tab.
-- It prefers the title that was set via `tab:set_title()`
-- or `wezterm cli set-tab-title`, but falls back to the
-- title of the active pane in that tab.
-- function tab_title(tab_info)
--   local title = tab_info.tab_title
--   -- if the tab title is explicitly set, take that
--   if title and #title > 0 then
--     return title
--   end
--   -- Otherwise, use the title from the active pane
--   -- in that tab
--   return tab_info.active_pane.title
-- end
--
-- wezterm.on(
--   'format-tab-title',
--   function(tab, tabs, panes, config, hover, max_width)
--     local edge_background = '#0b0022'
--     local background = '#1b1032'
--     local foreground = '#808080'
--
--     if tab.is_active then
--       background = '#2b2042'
--       foreground = '#c0c0c0'
--     elseif hover then
--       background = '#3b3052'
--       foreground = '#909090'
--     end
--
--     local edge_foreground = background
--
--     local title = tab_title(tab)
--
--     -- ensure that the titles fit in the available space,
--     -- and that we have room for the edges.
--     title = wezterm.truncate_right(title, max_width - 2)
--
--     return {
--       { Background = { Color = edge_background } },
--       { Foreground = { Color = edge_foreground } },
--       { Text = SOLID_LEFT_ARROW },
--       { Background = { Color = background } },
--       { Foreground = { Color = foreground } },
--       { Text = title },
--       { Background = { Color = edge_background } },
--       { Foreground = { Color = edge_foreground } },
--       { Text = SOLID_RIGHT_ARROW },
--     }
--   end
-- )
--
-- config.tab_bar_style = {
-- 	active_tab_left = wezterm.format({
-- 		{ Background = { Color = "#81A1C1" } },
-- 		{ Foreground = { Color = "#4C566A" } },
-- 		{ Text = SOLID_LEFT_ARROW },
-- 	}),
-- 	active_tab_right = wezterm.format({
-- 		{ Background = { Color = "#81A1C1" } },
-- 		{ Foreground = { Color = "#4C566A" } },
-- 		{ Text = SOLID_RIGHT_ARROW },
-- 	}),
-- 	inactive_tab_left = wezterm.format({
-- 		{ Background = { Color = "#0b0022" } },
-- 		{ Foreground = { Color = "#1b1032" } },
-- 		{ Text = SOLID_LEFT_ARROW },
-- 	}),
-- 	inactive_tab_right = wezterm.format({
-- 		{ Background = { Color = "#0b0022" } },
-- 		{ Foreground = { Color = "#1b1032" } },
-- 		{ Text = SOLID_RIGHT_ARROW },
-- 	}),
-- }

-- and finally, return the configuration to wezterm
return config
