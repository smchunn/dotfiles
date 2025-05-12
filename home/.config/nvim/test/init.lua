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
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			image = {},
			scroll = { enabled = true },
			picker = { enabled = true },
		},
  -- stylua: ignore
  keys = {
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    -- { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    -- { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
    -- { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    -- { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    -- { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
  },
		init = function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VeryLazy",
				callback = function()
					-- Setup some globals for debugging (lazy-loaded)
					_G.dd = function(...)
						Snacks.debug.inspect(...)
					end
					_G.bt = function()
						Snacks.debug.backtrace()
					end
					vim.print = _G.dd -- Override print to use snacks for `:=` command

					-- Create some toggle mappings
					Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
					Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
					Snacks.toggle.diagnostics():map("<leader>ud")
					Snacks.toggle.treesitter():map("<leader>uT")
					Snacks.toggle.inlay_hints():map("<leader>uh")
					Snacks.toggle.indent():map("<leader>ug")
					Snacks.toggle.dim():map("<leader>uD")
				end,
			})
		end,
	},
	{ "nvim-tree/nvim-web-devicons" },
	{
		"ibhagwan/fzf-lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local fzf = require("fzf-lua")

			-- Custom highlight group for icon space (for parity)
			vim.api.nvim_set_hl(0, "FzfLuaIconSpaceNoBlend", { fg = "#000000", blend = 0 })

			fzf.setup({
				winopts = {
					winblend = 10,
					width = 0.8,
					height = 0.85,
					row = 0.35,
					col = 0.50,
					border = "rounded",
					preview = {
						layout = "flex",
						vertical = "down:60%",
						horizontal = "right:50%",
						wrap = "nowrap",
						border = "border",
					},
				},
				fzf_opts = {
					-- ["--layout"] = "reverse",
					-- ["--info"] = "inline",
					["--prompt"] = " λ ",
				},
				-- Default options for all pickers
				files = {
					prompt = " λ Files> ",
					-- fd_opts = [[--color=never --type f --hidden --exclude .git]],
					rg_opts = [[--color=never --no-heading --with-filename --line-number --column --smart-case --hidden --trim --glob !**/.git/*]],
					git_icons = true,
					file_icons = true,
					color_icons = true,
				},
				grep = {
					rg_opts = [[--color=never --no-heading --with-filename --line-number --column --smart-case --hidden --trim --glob !**/.git/*]],
				},
				buffers = {
					actions = {
						["ctrl-d"] = require("fzf-lua.actions").buf_del,
					},
				},
				git = {},
				previewers = {
					cat = {
						cmd = "head",
						args = { "-c", "10000" },
					},
					snacks_image = { enabled = false },
				},
				keymap = {
					builtin = {
						["<C-p>"] = "toggle-preview",
					},
				},
			})

			-- Key mappings for launching fzf-lua pickers
			vim.keymap.set("n", "<leader>ff", function()
				fzf.files()
			end, { desc = "Find Files (fzf-lua)" })
			vim.keymap.set("n", "<leader>fg", function()
				fzf.live_grep()
			end, { desc = "Live Grep (fzf-lua)" })
			vim.keymap.set("n", "<leader>fb", function()
				fzf.buffers()
			end, { desc = "Buffers (fzf-lua)" })
			vim.keymap.set("n", "<leader>fs", function()
				fzf.git_stash()
			end, { desc = "Git Stash (fzf-lua)" })
		end,
	},
})
