local utils = require("smchunn.core.utils")

return {
  "nvimdev/dashboard-nvim",
  opts = function()
    local opts = {
      theme = "doom",
      disable_move = true,
      hide = {
        statusline = false,
      },
      config = {
        -- stylua: ignore
        header = {
          [[]], [[]], [[]], [[]], [[]], [[]], [[]], [[]],
          [[   ________  ________   ________  ________ ]],
          [[  /    /   \/    /   \ /        \/        \]],
          [[ /         /         /_/       //         /]],
          [[/         /\        //         /         / ]],
          [[\__/_____/  \______/ \________/\__/__/__/  ]],
          [[]], [[]], [[]], [[]], [[]],
        },
        -- stylua: ignore
        center = {
          { action = utils.file_picker, desc = " Find file", icon = " ", key = "f" },
          { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
          { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r" },
          { action = "Telescope egrepify", desc = " Find text", icon = " ", key = "g" },
          -- { action = require('telescope.builtin').git_files({cwd="$HOME/Development/dotfiles/", show_untracked=true}), desc = " Config", icon = " ", key = "c" },
          -- { action = 'lua require("persistence").load()', desc = " Restore Session", icon = " ", key = "s" },
          { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
          { action = "qa", desc = " Quit", icon = " ", key = "q" },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- open dashboard after closing lazy
    vim.api.nvim_create_autocmd("WinClosed", {
      pattern = tostring(vim.api.nvim_get_current_win()),
      once = true,
      callback = function()
        if vim.o.filetype == "lazy" then
          vim.schedule(function()
            vim.api.nvim_exec_autocmds("UIEnter", { group = "dashboard" })
          end)
        end
      end,
    })

    -- Function to set options for the dashboard
    local function set_dashboard_options()
      print("set dash opt")
      vim.opt_local.scrolloff = 999
      vim.opt_local.mouse = ""
      vim.opt_local.fillchars = { eob = " " }
    end

    -- Function to reset options when entering a different buffer
    local function reset_dashboard_options()
      local current_buf = vim.api.nvim_get_current_buf()
      if
          vim.bo[current_buf].filetype ~= "TelescopePrompt"
          and vim.bo[current_buf].filetype ~= "TelescopeResults"
          and vim.bo[current_buf].filetype ~= "dashboard"
      then
        print("unset dash opt")
        vim.opt_local.scrolloff = 0
        vim.opt.mouse = "a"
        vim.opt_local.fillchars = { eob = "~" }
      end
    end

    -- Set up the FileType autocommand for dashboard
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dashboard",
      callback = function()
        set_dashboard_options()

        -- Create a BufEnter autocommand to reset options when entering a different buffer
        local buf_enter_id = vim.api.nvim_create_autocmd("BufEnter", {
          callback = reset_dashboard_options,
        })

        -- Create a BufDelete autocommand to remove the BufEnter autocommand when the dashboard buffer is deleted
        vim.api.nvim_create_autocmd("BufDelete", {
          buffer = 0,                              -- This refers to the current buffer (dashboard)
          callback = function()
            vim.api.nvim_del_autocmd(buf_enter_id) -- Remove the BufEnter autocommand
          end,
        })
      end,
    })

    return opts
  end,
}
