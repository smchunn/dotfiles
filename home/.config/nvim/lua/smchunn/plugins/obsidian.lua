return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  -- enabled = false,
  cmd = { "Obsidian" },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "main",
        path = "/Users/smchunn/Library/Mobile Documents/iCloud~md~obsidian/Documents/SC",
      },
    },
    notes_subdir = "inbox",
    new_notes_location = "notes_subdir",

    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M:%S",
    },

    ---@return table
    frontmatter = {
      func = function(note)
        -- Add the title of the note as an alias.
        if note.title then
          note:add_alias(note.title)
        end

        local out = { id = note.id, aliases = note.aliases, tags = note.tags }

        -- `note.metadata` contains any manually added fields in the frontmatter.
        -- So here we just make sure those fields are kept in the frontmatter.
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
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },
    },
  },
}
