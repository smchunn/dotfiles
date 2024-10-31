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
          { action = function () require("telescope.builtin").find_files() end, desc = " Find file", icon = " ", key = "f" },
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
          -- stylua: ignore
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

    return opts
  end,
}
