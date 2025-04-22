vim.opt.termguicolors = true

-- Set up Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://urldefense.com/v3/__https://github.com/folke/lazy.nvim.git__;!!O7V3aRRsHkZJLA!A7nR8c8xYe6RQvFNcH82JgEJ0h5daC1bIUFXgT3vtdy0M8qsUzwfjDIvXY8npfph6KL8f94bFFnscaU6B-YZyKhn$ ",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Define plugins
require("lazy").setup({
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{ "nvim-tree/nvim-web-devicons" },
})
vim.g.mapleader = " " -- Set leader to space

vim.keymap.set("n", "<leader>f", function()
	require("telescope.builtin").find_files()
end, { desc = "Telescope Find Files" })

local function my_entry_maker(entry)
	local make_entry = require("telescope.make_entry")
	local base_entry = make_entry.gen_from_file()(entry)
	local filename = base_entry.filename
	local ext = filename and filename:match("^.+%.(.+)$") or ""
	local icon, hl_group = require("nvim-web-devicons").get_icon(filename or "", ext)
	icon = icon or ""

	-- Compose the display string: icon + two spaces + filename
	local display_string = icon .. " " .. filename
	local icon_end = vim.fn.strdisplaywidth(icon)

	return {
		value = base_entry.value,
		ordinal = base_entry.ordinal,
		filename = filename,
		display = function()
			return display_string,
				{
					{ { 0, icon_end }, hl_group },
					{ { icon_end, icon_end + 1 }, "TelescopeBorder" },
				}
		end,
	}
end

require("telescope").setup({
	pickers = {
		find_files = {
			entry_maker = my_entry_maker,
		},
	},
})
