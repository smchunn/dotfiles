
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
      ["--layout"] = "reverse",
      ["--info"] = "inline",
      -- ["--prompt"] = " λ ",
    },
    files = {
      cwd_prompt = false,
      -- fd_opts = [[--color=never --hidden --type f --type l ]],
    },
    grep = {
      rg_opts = [[--color=never --no-heading --with-filename --line-number --column --smart-case --hidden --trim --glob !**/.git/*]],
    },
    buffers = {},
    git = {
      stash = {},
    },
    previewers = {
      bat = {
        cmd = "bat",
        args = { "--style=plain", "--color=always" },
      },
      builtin = {
        snacks_image = { enabled = false },
      },
    },
    keymap = {
      builtin = {
        ["<C-p>"] = "toggle-preview",
      },
    },
  },
  config = function(_, opts)
    require("fzf-lua").setup(opts)
    local fzflua = require("fzf-lua")
    -- Key mappings
    vim.keymap.set("n", "<leader>ff", function()
      fzflua.files({ resume = true })
    end, { desc = "Find Files (fzf-lua)" })
    vim.keymap.set("n", "<leader>fg", function()
      fzflua.live_grep()
    end, { desc = "Live Grep (fzf-lua)" })
    vim.keymap.set("n", "<leader>fb", function()
      fzflua.buffers()
    end, { desc = "Buffers (fzf-lua)" })
    vim.keymap.set("n", "<leader>fs", function()
      fzflua.git_stash()
    end, { desc = "Git Stash (fzf-lua)" })
    vim.keymap.set("n", "<leader>fh", function()
      fzflua.helptags()
    end, { desc = "Help (fzf-lua)" })
    vim.keymap.set("n", "<leader>fa", function()
      fzflua.builtin()
    end, { desc = "Pickers (fzf-lua)" })
  end,

  }
})
