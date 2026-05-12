return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = { "Obsidian" },
  keys = {
    { "<leader>cf", ":Obsidian quick_switch<CR>", desc = "Obsidian quick switch", },
    { "<leader>ct", ":Obsidian tags<CR>", desc = "Obsidian tags", },
    { "<leader>cg", ":Obsidian search<CR>", desc = "Obsidian search", },
    { "<leader>cn", ":Obsidian new<CR>", desc = "Obsidian new", },
    { "<leader>cN", ":Obsidian new_from_template<CR>", desc = "Obsidian new from template", },
    { "<leader>cT", ":Obsidian today<CR>", desc = "Obsidian today", },
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "main",
        path = "~/Documents/vault/",
      },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    templates = {
      folder = "templates",
      -- date_format = "%Y-%m-%d",
      -- time_format = "%H:%M:%S",
      date_format = "MM-DD",
      time_format = "HHmm",
    },

    frontmatter = {
      func = function(note)
        if note.title then
          note:add_alias(note.title)
        end

        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do
            out[k] = v
          end
        end

        return out
      end,
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

    completion = {
      blink = true,
      min_chars = 2,
    },
    picker = {
      name = "fzf-lua",
      note_mappings = {
        new = "<C-x>",
        insert_link = "<C-l>",
      },
      tag_mappings = {
        tag_note = "<C-x>",
        insert_tag = "<C-l>",
      },
    },
    callbacks = {
      enter_note = function(note) end,
    },
  },
}
