-- import null-ls plugin safely
local setup, null_ls = pcall(require, "null-ls")
if not setup then
	return
end

-- for conciseness
local formatting = null_ls.builtins.formatting -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters

-- configure null_ls
null_ls.setup({
	-- setup formatters & linters
	sources = {
		--  to disable file types use
		--  "formatting.prettier.with({disabled_filetypes = {}})" (see null-ls docs)
		formatting.prettierd.with({ -- Specify file types for Prettier
			filetypes = { "markdown" },
		}),
		null_ls.builtins.formatting.stylua.with({ -- Specify file types for Stylua
			filetypes = { "lua" },
		}),
	},
	-- configure format on save
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
	end,
})
