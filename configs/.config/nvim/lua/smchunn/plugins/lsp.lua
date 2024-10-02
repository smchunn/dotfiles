return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      { "antosha417/nvim-lsp-file-operations", config = true },
    },
    config = function()
      local keymap = vim.keymap -- for conciseness
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Buffer local mappings.
          -- stylua: ignore start
          keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", { desc = "Show LSP references", buffer = ev.buf, silent = true, noremap = true })      -- show definition, references
          keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration", buffer = ev.buf, silent = true, noremap = true })        -- go to declaration
          keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Show LSP definitions", buffer = ev.buf, silent = true, noremap = true })     -- show lsp definitions
          keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", { desc = "Show LSP implementations", buffer = ev.buf, silent = true, noremap = true }) -- show lsp implementations
          keymap.set( "n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Show LSP type definitions", buffer = ev.buf, silent = true, noremap = true }) -- show lsp type definitions
          keymap.set( { "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "See available code actions", buffer = ev.buf, silent = true, noremap = true })                                                                            -- see available code actions, in visual mode will apply to selection
          keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Smart rename", buffer = ev.buf, silent = true, noremap = true }) -- smart rename
          keymap.set( "n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show buffer diagnostics", buffer = ev.buf, silent = true, noremap = true })                                                                                                           -- show  diagnostics for file
          keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics", buffer = ev.buf, silent = true, noremap = true })                       -- show diagnostics for line
          keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic", buffer = ev.buf, silent = true, noremap = true })                   -- jump to previous diagnostic in buffer
          keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic", buffer = ev.buf, silent = true, noremap = true })                       -- jump to next diagnostic in buffer
          keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show documentation for what is under cursor", buffer = ev.buf, silent = true, noremap = true }) -- show documentation for what is under cursor
          -- stylua: ignore end
          keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "Restart LSP", buffer = ev.buf, silent = true, noremap = true }) -- mapping to restart lsp if necessary
        end,
      })
    end,
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
                    vim.env.VIMRUNTIME,
                    -- [vim.fn.expand("$vimruntime/lua")] = true,
                    -- [vim.fn.stdpath("config") .. "/lua"] = true,
                  },
                },
                format = {
                  enable = false,
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
        },
        on_attach = function(client, bufnr)
          if client.server_capabilities.documentFormattingProvider then
            local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
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
}
