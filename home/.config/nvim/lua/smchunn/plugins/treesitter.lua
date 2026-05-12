return {
  "romus204/tree-sitter-manager.nvim",
  config = function()
    require("tree-sitter-manager").setup({
      highlight = true,
      auto_install = true,
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "latex",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "c",
        "rust",
        "devicetree",
        "julia",
        "toml",
        "tmux",
        "python",
        "fish",
      },
    })
  end,
}
