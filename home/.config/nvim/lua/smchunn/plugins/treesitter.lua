return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
        -- disable = {
        --   "markdown",
        -- },
      },
      autotag = { enable = true },
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
      ignore_install = { "latex" },
      disable = { "latex" },
      auto_install = true,
      modules = {},
      sync_install = false,
    })
  end,
}
