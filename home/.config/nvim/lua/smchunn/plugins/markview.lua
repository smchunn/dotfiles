return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  -- enabled = false,
  -- Load before nvim-treesitter to avoid syntax issues
  priority = 49,
  dependencies = {
    "saghen/blink.cmp",
  },
  opts = {
    -- Enable LaTeX rendering
    latex = {
      enable = true,
      -- LaTeX block configuration ($$...$$)
      blocks = {
        enable = true,
      },
      -- Inline math configuration ($...$)
      inlines = {
        enable = true,
      },
      -- LaTeX commands like \frac{}{}, \sin{}, etc.
      commands = {
        enable = true,
      },
      -- Math symbols (Greek letters, operators, etc.)
      symbols = {
        enable = true,
      },
      -- Math fonts (\mathbb{}, \mathbf{}, etc.)
      fonts = {
        enable = true,
      },
      -- Subscripts
      subscripts = {
        enable = true,
      },
      -- Superscripts
      superscripts = {
        enable = true,
      },
      -- Escaped characters
      escapes = {
        enable = true,
      },
      -- Parenthesis rendering
      parenthesis = {
        enable = true,
      },
      -- \text{} command
      texts = {
        enable = true,
      },
    },
    -- Enable markdown rendering as well
    markdown = {
      enable = true,
    },
    markdown_inline = {
      enable = true,
    },
    -- Preview configuration
    preview = {
      enable = true,
      icon_provider = "devicons",
      filetypes = { "md", "rmd", "quarto", "markdown" },
      modes = { "n", "no", "c" },
      -- Optionally enable hybrid modes for editing while previewing
      -- hybrid_modes = { "n" },
    },
  },
}
