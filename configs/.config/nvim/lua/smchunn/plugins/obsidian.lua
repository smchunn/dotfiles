return {
  "epwalsh/obsidian.nvim",
  version = false,
  ft = "markdown",
  cmd = { "ObsidianQuickSwitch", "ObsidianNew" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "main",
        path = "~/Library/CloudStorage/OneDrive-MMC/Documents/vault/",
      },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M:%S",
    },

    note_id_func = function(title)
      local suffix = ""
      -- get current ISO datetime with -5 hour offset from UTC for EST
      local current_datetime = os.date("!%Y-%m-%d", os.time() - 5 * 3600)
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return current_datetime .. "-" .. suffix
    end,

    -- key mappings, below are the defaults
    mappings = {
      -- overrides the 'gf' mapping to work on markdown/wiki links within your vault
      ["gf"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      -- Toggle check-boxes.
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ["<cr>"] = {
        action = function()
          return require("obsidian").util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 2,
    },
    ui = {
      -- enable = false,
    },
  },
}
