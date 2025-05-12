vim.opt.termguicolors = true

-- Set up Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "test/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " " -- Set leader to space
-- Define plugins
require("lazy").setup({
	spec = {
		{
			"smchunn/nvim-tree.lua",
			dependencies = "nvim-tree/nvim-web-devicons",
			opts = {
				update_cwd = true,
				actions = {
					open_file = {
						window_picker = {
							enable = false,
						},
					},
				},
				hijack_directories = {
					enable = false,
				},
				renderer = {
					icons = {
						padding = { icon = "i", folder_arrow = "a" },
					},
				},
			},
		},
	},
	-- install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})

vim.keymap.set(
	"n",
	"<leader>e",
	":NvimTreeToggle<CR>",
	{ desc = "Toggle NvimTree", noremap = true, silent = true, nowait = true }
)
vim.keymap.set("n", "<leader>i", function()
	require("nvim-tree.api").tree.find_file({ open = true, focus = true })
end, { desc = "Open NvimTree to current buffer", noremap = true, silent = true, nowait = true })
