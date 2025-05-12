local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local function basename(s)
		return string.gsub(s, "(.*[/\\])(.*)", "%2")
	end

	local pane = tab.active_pane
	local index = tab.tab_index
	local title = " " .. (index + 1) .. " " .. wezterm.truncate_left(pane.title, max_width - 4) .. " "

	return {
		{ Text = title },
	}
end)
-- Domains
config.unix_domains = {
	{
		name = "unix",
	},
}

-- General settings
config.default_gui_startup_args = { "connect", "unix" }
-- config.term = "xterm-256color"
config.term = "wezterm"
config.scrollback_lines = 10000
config.switch_to_last_active_tab_when_closing_tab = true

-- Shell
config.default_prog = { "/run/current-system/sw/bin/fish", "-l" }

-- Keybindings
config.leader = {
	key = " ",
	mods = "CMD",
	timeout_milliseconds = 2000,
}
config.keys = {
	{ key = "=", mods = "CMD", action = wezterm.action.ResetFontSize },
	{ key = "+", mods = "SHIFT|CMD", action = wezterm.action.IncreaseFontSize },
	{ key = "H", mods = "CMD", action = wezterm.action.Hide },
	{ key = "Q", mods = "CMD", action = wezterm.action.QuitApplication },
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "n",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "p",
		mods = "LEADER",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		key = "w",
		mods = "LEADER",
		action = act.ShowTabNavigator,
	},
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentTab({ confirm = false }),
	},
}

-- Cursor
config.cursor_blink_rate = 600
config.default_cursor_style = "BlinkingUnderline"
config.mouse_bindings = {
	{
		event = { Down = { streak = 3, button = "Right" } },
		action = act.SelectTextAtMouseCursor("SemanticZone"),
	},
}
------------------------------------------------------------------------------
-- UI
------------------------------------------------------------------------------
config.window_decorations = "TITLE | RESIZE"
config.initial_cols = 80
config.initial_rows = 25
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
config.window_background_opacity = 0.92
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.show_tab_index_in_tab_bar = true
config.bold_brightens_ansi_colors = true
config.tab_max_width = 32
-- config.use_cap_height_to_scale_fallback_fonts = true
-- Font
-- config.allow_square_glyphs_to_overflow_width = "Never"
config.font = wezterm.font_with_fallback({
	-- {
	-- 	family = "IosevkaSC Nerd Font",
	-- 	style = "Normal",
	-- 	harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	-- 	weight = "Light",
	-- 	stretch = "Expanded",
	-- },
	{
		family = "Iosevka Term",
		style = "Normal",
		harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
		weight = "Light",
	},
	{
		family = "JetBrains Mono",
		assume_emoji_presentation = true,
		style = "Normal",
	},
	{
		family = "Symbols Nerd Font Mono",
		scale = 1.0,
	},
})
config.font_size = 16.0

-- Colors
config.colors = {
	foreground = "#bdbdbd",
	background = "#080808",
	cursor_fg = "#080808",
	cursor_bg = "#9e9e9e",
	-- selection_fg = "#080808",
	-- selection_bg = "#b2ceee",
	selection_fg = "#080808",
	selection_bg = "#e3c78a",
	ansi = {
		"#323437", -- black
		"#ff5454", -- red
		"#8cc85f", -- green
		"#e3c78a", -- yellow
		"#80a0ff", -- blue
		"#cf87e8", -- magenta
		"#79dac8", -- cyan
		"#c6c6c6", -- white
	},
	brights = {
		"#949494", -- black
		"#ff5189", -- red
		"#36c692", -- green
		"#c2c292", -- yellow
		"#74b2ff", -- blue
		"#ae81ff", -- magenta
		"#85dc85", -- cyan
		"#e4e4e4", -- white
	},
	tab_bar = {
		background = "#2e2e2e",
		active_tab = {
			bg_color = "#80a0ff",
			fg_color = "#1c1c1c",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#2e2e2e",
			fg_color = "#949494",
		},
		inactive_tab_hover = {
			bg_color = "#262626",
			fg_color = "#949494",
			italic = false,
		},
	},
}
return config
