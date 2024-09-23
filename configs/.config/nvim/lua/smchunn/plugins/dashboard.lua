local utils = require("smchunn.core.utils")

return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
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
          [[]], [[]], [[]], [[]], [[]],
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

    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        pattern = "DashboardLoaded",
        callback = function()
          require("lazy").show()
        end,
      })
    end
    -- Disable scrolling when the dashboard is active

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dashboard",
      callback = function()
        vim.opt_local.scrolloff = 999
        vim.opt_local.mouse = ""
        vim.opt_local.fillchars = { eob = " " }
        -- vim.api.nvim_create_autocmd("BufLeave", {
        --   buffer = 0,
        --   callback = function()
        --     vim.opt_local.scrolloff = 0
        --     vim.opt.mouse = "a"
        --     vim.opt.fillchars = { eob = "~" }
        --   end,
        -- })
      end,
    })

    vim.api.nvim_create_autocmd("BufNew", {
      pattern = "",
      group = vim.api.nvim_create_augroup("open-dashboard-after-last-buffer-close", { clear = true }),
      callback = function(event)
        for buf = 1, vim.fn.bufnr("$") do
          if buf ~= event.buf and vim.fn.buflisted(buf) == 1 then
            if vim.api.nvim_buf_get_name(buf) ~= "" and vim.bo[buf].filetype ~= "dashboard" then
              return
            end
          end
        end

        vim.cmd("Dashboard")
      end,
    })
    return opts
  end,
}
