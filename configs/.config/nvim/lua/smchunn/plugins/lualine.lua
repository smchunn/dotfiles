-- import lualine plugin safely
local lualine_status, lualine = pcall(require, "lualine")
if not lualine_status then
	return
end

-- get lualine moonfly theme
local moonfly_status, lualine_moonfly = pcall(require, "lualine.themes.moonfly")
if not moonfly_status then
  return
end

-- new colors for theme
local mf_colors = {
	Background = "#808080",
	Foreground = "#bdbdbd",
	Bold = "#eeeeee",
	Cursor = "#9e9e9e",
	CursorText = "#808080",
	Selection = "#b2ceee",
	SelectionText = "#808080",
	Black = "#323437",
	Red = "#ff5454",
	Green = "#8cc85f",
	Yellow = "#e3c78a",
	Blue = "#80a0ff",
	Purple = "#cf87e8",
	Cyan = "#79dac8",
	White = "#c6c6c6",
	bBlack = "#949494",
	bRed = "#ff5189",
	bGreen = "#36c692",
	bYellow = "#c2c292",
	bBlue = "#74b2ff",
	bPurple = "#ae81ff",
	bCyan = "#85dc85",
	bWhite = "#e4e4e4",
	uStatusForeground = "#1c1c1c",
}

-- change moonlfy theme colors
lualine_moonfly.normal.a.bg = mf_colors.Blue
lualine_moonfly.insert.a.bg = mf_colors.Green
lualine_moonfly.visual.a.bg = mf_colors.Purple
lualine_moonfly.command = {
	a = {
		gui = "bold",
		bg = mf_colors.Yellow,
		fg = mf_colors.uStatusForeground, -- black
	},
}

-- configure lualine with modified theme
lualine.setup({
	options = {
		theme = lualine_moonfly,
		disabled_filetypes = { "packer", "NvimTree" },
	},
})
