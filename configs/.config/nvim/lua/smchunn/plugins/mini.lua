return {
  {
    "echasnovski/mini.ai",
    version = false,
    opts = {},
  },
  {
    "echasnovski/mini.align",
    version = false,
    opts = {},
    keys = {
      { "ga", mode = { "n", "v" } },
      { "gA", mode = { "n", "v" } },
    },
  },
  {
    "echasnovski/mini.comment",
    version = false,
    lazy = true,
    opts = {},
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = { "n" } },
    },
  },
  {
    "echasnovski/mini.diff",
    version = false,
    lazy = false,
    opts = {
      view = {
        style = "sign",
        signs = { add = "▎", change = "▎", delete = "" },
      },
    },
  },
  {
    "echasnovski/mini.indentscope",
    version = false,
    opts = {},
  },
  {
    "echasnovski/mini.operators",
    version = false,
    lazy = true,
    keys = {
      { "gx" },
      { "gm" },
      { "gr" },
      { "gs" },
    },
    opts = {},
  },
  {
    "echasnovski/mini.pairs",
    version = false,
    event = "InsertEnter",
    opts = {
      modes = { insert = true, command = true, terminal = false },

      mappings = {
        ["("] = { action = "open", pair = "()", neigh_pattern = "[^\\]." },
        ["["] = { action = "open", pair = "[]", neigh_pattern = "[^\\]." },
        ["{"] = { action = "open", pair = "{}", neigh_pattern = "[^\\]." },

        [")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
        ["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
        ["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },

        ['"'] = {
          action = "closeopen",
          pair = '""',
          neigh_pattern = "[^\\].",
          register = { cr = false },
        },
        ["'"] = {
          action = "closeopen",
          pair = "''",
          neigh_pattern = "[^%a\\].",
          register = { cr = false },
        },
        ["`"] = {
          action = "closeopen",
          pair = "``",
          neigh_pattern = "[^\\].",
          register = { cr = false },
        },
      },
    },
  },
  {
    "echasnovski/mini.surround",
    version = false,
    keys = {
      { "ys" },
      { "ds" },
      { "cs" },
    },
    opts = {
      highlight_duration = 500,
      mappings = {
        add = "ys", -- Add surrounding in Normal and Visual modes
        delete = "ds", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "", -- Highlight surrounding
        replace = "cs", -- Replace surrounding
        update_n_lines = "gsu", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },

      n_lines = 20,

      -- Whether to respect selection type:
      -- - Place surroundings on separate lines in linewise mode.
      -- - Place surroundings on each line in blockwise mode.
      respect_selection_type = false,

      -- How to search for surrounding (first inside current line, then inside
      -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
      -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
      -- see `:h MiniSurround.config`.
      search_method = "cover",

      silent = true,
    },
  },
}
