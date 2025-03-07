return {
	"bluz71/vim-moonfly-colors",
        cond = vim.env.TERM_PROGRAM ~= "Apple_Terminal",
	name = "moonfly",
	lazy = false,
	priority = 1000,
	config = function()
		-- load the colorscheme here
		vim.cmd([[colorscheme moonfly]])
	end,
}
