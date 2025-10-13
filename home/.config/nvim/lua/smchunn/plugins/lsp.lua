return {
  --------------------
  -- nvim-lspconfig --
  --------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      -- "hrsh7th/cmp-nvim-lsp",
      { "antosha417/nvim-lsp-file-operations", config = true },
      "folke/lazydev.nvim",
    },
  },

  -------------------
  -- mason-lspconfig
  -------------------
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "pyright",
        "rust_analyzer",
        -- "julials",
        "jinja_lsp",
        "ts_ls", -- TypeScript/JavaScript
        "tailwindcss", -- Tailwind CSS
        "eslint", -- ESLint
        "cssls", -- CSS
        "html", -- HTML
        "jsonls",
      },
      automatic_installation = true,
      handlers = {
        -- default handler for installed servers
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = require("blink.cmp").get_lsp_capabilities(),
          })
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = require("blink.cmp").get_lsp_capabilities(),
            settings = {
              lua = {
                runtime = {
                  version = "LuaJIT",
                },
                diagnostics = {
                  globals = { "vim", "require" },
                },
                workspace = {
                  library = {
                    -- vim.env.VIMRUNTIME,
                    [vim.fn.expand("$vimruntime/lua")] = true,
                    [vim.fn.stdpath("config") .. "/lua"] = true,
                  },
                },
                format = {
                  enable = false,
                },
              },
            },
          })
        end,
        ["tailwindcss"] = function()
          require("lspconfig").tailwindcss.setup({
            capabilities = require("blink.cmp").get_lsp_capabilities(),
            filetypes = {
              "html",
              "css",
              "scss",
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
            },
            settings = {
              tailwindCSS = {
                experimental = {
                  classRegex = {
                    -- Support for cva, clsx, cn, etc.
                    { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                    { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                    "class[:]\\s*['\"`]([^'\"`]*)['\"`]",
                  },
                },
              },
            },
          })
        end,

        -- ESLint with auto-fix on save
        ["eslint"] = function()
          require("lspconfig").eslint.setup({
            capabilities = require("blink.cmp").get_lsp_capabilities(),
            on_attach = function(client, bufnr)
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                command = "EslintFixAll",
              })
            end,
          })
        end,

        -- rust-analyzer with clippy
        ["rust_analyzer"] = function()
          require("lspconfig").rust_analyzer.setup({
            capabilities = require("blink.cmp").get_lsp_capabilities(),
            settings = {
              ["rust-analyzer"] = {
                cargo = {
                  allFeatures = true,
                },
                checkOnSave = {
                  command = "clippy",
                },
              },
            },
          })
        end,
      },
    },
  },

  ---------
  -- mason
  ---------
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {},
        border = "single",
      },
      PATH = "append",
    },
  },

  -----------------
  -- mason-null-ls
  -----------------
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvimtools/none-ls.nvim",
    },
    opts = {
      ensure_installed = {
        "prettier", -- general formatter
        -- "stylua", -- lua formatter
        "black", -- python formatter
        -- "alejandra",
      },
      automatic_installation = true,
    },
  },

  -----------
  -- none-ls
  -----------
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting

      local lsp_formatting = function(bufnr)
        vim.lsp.buf.format({
          filter = function(client)
            return client.name == "null-ls"
          end,
          bufnr = bufnr,
        })
      end

      null_ls.setup({
        sources = {
          -- Prettier for JS/TS/React/CSS/HTML/JSON
          formatting.prettier.with({
            filetypes = {
              "javascript",
              "javascriptreact",
              "typescript",
              "typescriptreact",
              "css",
              "scss",
              "html",
              "json",
              "yaml",
              "markdown",
            },
            disabled_filetypes = { "lua" },
          }),
          formatting.stylua.with({
            filetypes = { "lua" },
          }),
          formatting.black.with({
            filetypes = { "python" },
          }),
          formatting.alejandra.with({
            command = "alejandra",
            filetypes = { "nix" },
          }),
        },
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentFormattingProvider then
            local format_group =
              vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = format_group,
              buffer = bufnr,
              callback = function()
                lsp_formatting(bufnr)
              end,
            })
          end
        end,
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {},
  },
}
