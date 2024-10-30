return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "fdschmidt93/telescope-egrepify.nvim",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")
    local utils = require("smchunn.core.utils")

    telescope.setup({
      defaults = {
        prompt_prefix = " λ ",
        selection_caret = "󰁕 ",
        path_display = { "smart" },
        winblend = 10,
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden", -- Include hidden files
          "--trim",
          "--glob",
          "!**/.git/*", -- Exclude .git directory
        },
        cache_picker = {
          num_pickers = 10,
        },
        layout_config = {
          width = 0.8,
          prompt_position = "top",
          preview_cutoff = 120,
        },
        color_devicons = true,
        use_less = true,
        mappings = {
          i = {
            ["<C-h>"] = actions.select_horizontal,
            ["<C-o>"] = require("smchunn.core.utils").actions.open_and_resume,
            ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            ["<C-s>"] = require("smchunn.core.utils").actions.open_in_nvim_tree,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
          },
        },
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
        },
        git_stash = {
          mappings = {
            i = {
              ["<C-f>"] = require("smchunn.core.utils").actions.show_git_stash_files,
            },
          },
        },
        buffers = {
          mappings = {
            i = {
              ["<C-d>"] = actions.delete_buffer,
            },
          },
        },
      },
      extensions = {
        egrepify = {},
      },
    })

    -- Key mappings

    telescope.load_extension("fzf")
  end,
}
