return {
  {
    "echasnovski/mini.ai",
    version = false,
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({
            a = "@function.outer",
            i = "@function.inner",
          }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
  },
  {
    "echasnovski/mini.align",
    version = false,
    opts = {},
    keys = {
      { "<leader>a", mode = { "n", "v" } },
      { "<leader>A", mode = { "n", "v" } },
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
    "echasnovski/mini.operators",
    version = false,
    opts = {
      exchange = {
        prefix = "gx",
        reindent_linewise = true,
      },
      multiply = {
        prefix = "gm",
        func = nil,
      },
      replace = {
        prefix = "gp",
        reindent_linewise = true,
      },
      sort = {
        prefix = "gs",
        func = nil,
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    version = false,
    event = "InsertEnter",
    opts = {
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
    opts = {
      mappings = {
        add = "<leader>ma", -- Add surrounding in Normal and Visual modes
        delete = "<leader>md", -- Delete surrounding
        find = "<leader>mf", -- Find surrounding (to the right)
        find_left = "<leader>mF", -- Find surrounding (to the left)
        highlight = "<leader>mh", -- Highlight surrounding
        replace = "<leader>mr", -- Replace surrounding
        update_n_lines = "<leader>mn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },

      respect_selection_type = false,

      search_method = "cover",

      silent = true,
    },
  },
}
