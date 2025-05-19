return {
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
      git_icons = true,
      file_icons = true,
      color_icons = true,
      actions = {
        ["ctrl-h"] = "split",
        ["ctrl-o"] = "edit",
        ["ctrl-q"] = "sel_qf",
      },
    },
    grep = {
      rg_opts = [[--color=never --no-heading --with-filename --line-number --column --smart-case --hidden --trim --glob !**/.git/*]],
      actions = {
        ["ctrl-q"] = "sel_qf",
      },
    },
    buffers = {
      actions = {
        ["ctrl-d"] = "bufdel",
      },
    },
    git = {
      stash = {
        actions = {},
      },
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
    -- Key mappings
    vim.keymap.set("n", "<leader>ff", function()
      require("fzf-lua").files()
    end, { desc = "Find Files (fzf-lua)" })
    vim.keymap.set("n", "<leader>fg", function()
      require("fzf-lua").live_grep()
    end, { desc = "Live Grep (fzf-lua)" })
    vim.keymap.set("n", "<leader>fb", function()
      require("fzf-lua").buffers()
    end, { desc = "Buffers (fzf-lua)" })
    vim.keymap.set("n", "<leader>fs", function()
      require("fzf-lua").git_stash()
    end, { desc = "Git Stash (fzf-lua)" })
    vim.keymap.set("n", "<leader>fh", function()
      require("fzf-lua").helptags()
    end, { desc = "Help (fzf-lua)" })
  end,
}
