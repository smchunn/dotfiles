return {
  --------------------
  -- nvim-lspconfig --
  --------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
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
        "julials",
        "rust_analyzer",
        "jinja_lsp",
        "marksman",
      },
      automatic_installation = true,
      handlers = {
        -- default handler for installed servers
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end,
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
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
                  enable = true,
                },
              },
            },
          })
        end,
        ["marksman"] = function()
          require("lspconfig").marksman.setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
            filetypes = { "markdown" }, -- Ensure Marksman attaches to Markdown files
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
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
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
        "stylua", -- lua formatter
        "black", -- python formatter
      },
      automatic_installation = true,
    },
  },

  -----------
  -- none-ls
  -----------
  {
    "nvimtools/none-ls.nvim",
    opts = function()
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting

      local lsp_formatting = function(bufnr)
        vim.lsp.buf.format({
          filter = function(client)
            -- apply whatever logic you want (in this example, we'll only use null-ls)
            return client.name == "null-ls"
          end,
          bufnr = bufnr,
        })
      end

      null_ls.setup({
        sources = {
          formatting.prettierd.with({
            filetypes = { "markdown" },
            disabled_filetypes = { "lua" },
          }),
          formatting.stylua.with({
            filetypes = { "lua" },
          }),
          formatting.black.with({
            filetypes = { "python" },
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
