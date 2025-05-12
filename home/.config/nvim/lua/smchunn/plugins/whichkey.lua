return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    disable = {
      ft = { "dashboard" },
      bt = {},
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = true })
      end,
      desc = "Global Keymaps (which-key)",
    },
    {
      "<localleader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
