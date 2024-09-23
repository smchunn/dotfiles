local M = { actions = {}, previewers = {} }

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
          "!.git/*", -- Exclude .git directory
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
            ["<C-o>"] = M.actions.open_and_resume,
            ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            ["<C-s>"] = M.actions.open_in_nvim_tree,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            ["<esc>"] = actions.close,
          },
          n = {
            ["<C-h>"] = actions.select_horizontal,
            ["<C-o>"] = M.actions.open_and_resume,
            ["<C-p>"] = require("telescope.actions.layout").toggle_preview,
            ["<C-s>"] = M.actions.open_in_nvim_tree,
          },
        },
      },
      pickers = {
        git_stash = {
          mappings = {
            i = {
              ["<C-f>"] = M.actions.show_git_stash_files,
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
    vim.keymap.set("n", "<c-f>", "<cmd>Telescope egrepify<cr>",
      { desc = "Telescope Egrepify", silent = true, noremap = true })

    vim.keymap.set("n", "<leader>f", utils.file_picker, { desc = "Telescope File Picker", silent = true, noremap = true })

    vim.keymap.set("n", "<leader>rr", builtin.resume, { desc = "Telescope Resume", silent = true, noremap = true })
    vim.keymap.set("n", "<leader>rp", builtin.pickers,
      { desc = "Telescope Recent Pickers", silent = true, noremap = true })
    vim.keymap.set("n", "<leader>cf", builtin.filetypes, { desc = "Telescope Filetypes", silent = true, noremap = true })
    vim.keymap.set("n", "<leader>bb", builtin.buffers, { desc = "Telescope Buffers", silent = true, noremap = true })
    vim.keymap.set("n", "<localleader>h", builtin.help_tags, { desc = "Telescope help", silent = true, noremap = true })
    vim.keymap.set("n", "<C-_>", builtin.current_buffer_fuzzy_find,
      { desc = "Telescope Search Buffer", silent = true, noremap = true })
    vim.keymap.set("n", "<localleader>gb", builtin.git_branches,
      { desc = "Teleccope Git Branches", silent = true, noremap = true })
    vim.keymap.set("n", "<localleader>gc", builtin.git_commits,
      { desc = "Telescope Git Commits", silent = true, noremap = true })
    vim.keymap.set("n", "<localleader>gf", builtin.git_bcommits,
      { desc = "Telescope Git Commits(buffer)", silent = true, noremap = true })
    vim.keymap.set("n", "<localleader>gs", builtin.git_stash,
      { desc = "Telescope Git Stash", silent = true, noremap = true })
    vim.keymap.set("n", "<localleader>gt", builtin.git_status,
      { desc = "Telescope Git Status", silent = true, noremap = true })
    vim.keymap.set("n", "z=", ":Telescope spell_suggest<CR>",
      { desc = "Telescope Spell Suggest", silent = true, noremap = true })

    function M.actions.git_apply_stash_file(stash_id)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      return function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selection = picker:get_multi_selection()
        if #selection == 0 then
          selection = { picker:get_selection() }
        end

        local files = {}
        for _, sel in ipairs(selection) do
          table.insert(files, sel[1])
        end
        local git_command = {
          "sh",
          "-c",
          "git --no-pager diff HEAD.." .. " | git apply -",
        }

        local _, ret, stderr = utils.get_os_command_output(git_command)
        if ret == 0 then
          print("Applied stash files from " .. stash_id)
        else
          print("Error applying stash " .. vim.inspect(stderr))
        end
        actions.close(prompt_bufnr)
      end
    end

    function M.actions.show_git_stash_files()
      local actions = require("telescope.actions")
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local action_state = require("telescope.actions.state")
      local telescope_config = require("telescope.config").values

      local selection = action_state.get_selected_entry()
      if selection == nil or selection.value == nil or selection.value == "" then
        return
      end

      local stash_id = selection.value

      local opts = {}
      local p = pickers.new(opts, {
        prompt_title = "Files in " .. stash_id,
        finder = finders.new_oneshot_job({
          "git",
          "--no-pager",
          "stash",
          "show",
          stash_id,
          "--name-only",
        }, opts),
        previewer = M.previewers.git_stash_file(stash_id, opts),
        sorter = telescope_config.file_sorter(opts),
        attach_mappings = function()
          actions.select_default:replace(M.actions.git_apply_stash_file(stash_id))
          return true
        end,
      })
      p:find()
    end

    function M.previewers.git_stash_file(stash_id, opts)
      local putils = require("telescope.previewers.utils")
      local previewers = require("telescope.previewers")

      return previewers.new_buffer_previewer({
        title = "Stash file preview",
        get_buffer_by_name = function(_, entry)
          return entry.value
        end,
        define_preview = function(self, entry, _)
          local cmd = { "git", "--no-pager", "diff", stash_id, "--", entry.value }
          putils.job_maker(cmd, self.state.bufnr, {
            value = entry.value,
            bufname = self.state.bufname,
            cwd = opts.cwd,
            callback = function(bufnr)
              if vim.api.nvim_buf_is_valid(bufnr) then
                putils.regex_highlighter(bufnr, "diff")
              end
            end,
          })
        end,
      })
    end

    function M.actions.open_and_resume(prompt_bufnr)
      require("telescope.actions").select_default(prompt_bufnr)
      require("telescope.builtin").resume()
    end

    function M.actions.open_in_nvim_tree(prompt_bufnr)
      local action_state = require("telescope.actions.state")
      local actions = require("telescope.actions")
      local nvim_tree_api = require("nvim-tree.api")

      local selection = action_state.get_selected_entry()
      if not selection then
        print("No selection made")
        return
      end

      local selection_path = selection.value

      actions.close(prompt_bufnr)

      nvim_tree_api.tree.open()
      nvim_tree_api.tree.find_file({ buf = selection_path, open = true })
    end

    telescope.load_extension("fzf")
  end,
}
