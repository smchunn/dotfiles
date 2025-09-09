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

vim.g.mapleader = " " -- Set leader to space
-- Define plugins
require("lazy").setup({
	{
		"ibhagwan/fzf-lua",
		version = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			files = {
				cwd_prompt = false,
				-- fd_opts = [[--color=never --hidden --type f --type l ]],
				-- git_icons = true,
				-- file_icons = true,
				-- color_icons = true,
				actions = {
					["ctrl-h"] = "split",
					["ctrl-o"] = "edit",
					["ctrl-q"] = "sel_qf",
				},
			},
		},
	},
})
