return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    {
      "jay-babu/mason-null-ls.nvim",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = {
        "nvimtools/none-ls.nvim",
      },
      opts = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting
		-- local diagnostics = null_ls.builtins.diagnostics
		-- local code_actions = null_ls.builtins.code_actions
		-- local completion = null_ls.builtins.completion

		-- Setup formatters & linters
		-- Configure format on save
		 null_ls.setup({
			sources = {
			-- To disable file types use
			formatting.prettierd.with({
				-- Specify file types for Prettier
				filetypes = { "markdown" },
			}),
			formatting.stylua.with({
				-- Specify file types for Stylua
				filetypes = { "lua" },
			}),
		} ,
			on_attach = function(client, bufnr)
			if client.server_capabilities.documentFormattingProvider then
				local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
				vim.api.nvim_create_autocmd("BufWritePre", {
					group = format_group,
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format()
					end,
				})
			end
		end ,
		})
	end,
    }
  },
  opts = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_null_ls = require("mason-null-ls")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = {
        "lua_ls",
        "pyright",
        "julials",
        "rust_analyzer",
        "jinja_lsp",
      },
      automatic_installation = true,
    })

    mason_null_ls.setup({
      ensure_installed = {
        "prettier", -- general formatter
        "stylua", -- lua formatter
      },
      automatic_installation = true,
    })
  end,
}
