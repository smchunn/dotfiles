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
    vim.api.nvim_set_hl(0, "TelescopeIconSpaceNoBlend", { fg = "#000000", blend = 0 })

    local function my_entry_maker(entry)
      local make_entry = require("telescope.make_entry")
      local base_entry = make_entry.gen_from_file()(entry)
      local ext = base_entry.filename and base_entry.filename:match("^.+%.(.+)$") or ""
      local icon, hl_group =
        require("nvim-web-devicons").get_icon(base_entry.filename or "", ext)
      icon = icon or ""
      hl_group = hl_group or ""

      local display_string = icon .. " " .. base_entry.filename

      return {
        value = base_entry.value,
        ordinal = base_entry.ordinal,
        filename = base_entry.filename,
        display = function()
          return display_string,
            {
              { { 0, #icon }, hl_group },
              { { #icon, #icon + 1 }, "TelescopeIconSpaceNoBlend" },
            }
        end,
      }
    end
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
          entry_maker = my_entry_maker,
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
      preview = {
        filesize_hook = function(filepath, bufnr, opts)
          local max_bytes = 10000
          local cmd = { "head", "-c", max_bytes, filepath }
          require("telescope.previewers.utils").job_maker(cmd, bufnr, opts)
        end,
      },
    })

    -- Key mappings

    telescope.load_extension("fzf")
  end,
}
