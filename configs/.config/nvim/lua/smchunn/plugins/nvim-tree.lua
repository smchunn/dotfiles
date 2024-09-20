
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local HEIGHT_RATIO = 0.8
local WIDTH_RATIO = 0.5

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

nvimtree.setup({
	update_cwd = true,
	renderer = {
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "󰧂",
					arrow_open = "󰦺",
				},
			},
		},
	},
	-- disable window_picker for
	-- explorer to work well with
	-- window splits
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
	hijack_directories = {
		enable = false,
	},
	view = {
		float = {
			enable = true,
			open_win_config = function()
				local screen_w = vim.opt.columns:get()
				local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
				local window_w = screen_w * WIDTH_RATIO
				local window_h = screen_h * HEIGHT_RATIO
				local window_w_int = math.floor(window_w)
				local window_h_int = math.floor(window_h)
				local center_x = (screen_w - window_w) / 2
				local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
				return {
					border = "rounded",
					relative = "editor",
					row = center_y,
					col = center_x,
					width = window_w_int,
					height = window_h_int,
				}
			end,
		},
		width = function()
			return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
		end,
	},
	on_attach = nvim_tree_on_attach,
	-- 	git = {
	-- 		ignore = false,
	-- 	},
})

-- open nvim-tree on setup
local function open_nvim_tree(data)
	-- buffer is a [No Name]
	local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

	-- buffer is a directory
	local directory = vim.fn.isdirectory(data.file) == 1

	if not no_name and not directory then
		return
	end

	-- change to the directory
	if directory then
		vim.cmd.cd(data.file)
	end

	-- open the tree
	require("nvim-tree.api").tree.open()
end

-- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

local function nvim_tree_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	local function change_root_to_node(node)
		if node == nil then
			node = api.tree.get_node_under_cursor()
		end

		if node ~= nil and node.type == "directory" then
			vim.api.nvim_set_current_dir(node.absolute_path)
		end
		api.tree.change_root_to_node(node)
	end

	local function change_root_to_parent(node)
		local abs_path
		if node == nil then
			abs_path = api.tree.get_nodes().absolute_path
		else
			abs_path = node.absolute_path
		end

		local parent_path = vim.fs.dirname(abs_path)
		vim.api.nvim_set_current_dir(parent_path)
		api.tree.change_root(parent_path)
	end

	vim.keymap.set("n", "<C-]>", change_root_to_node, opts("CD"))
	vim.keymap.set("n", "<2-RightMouse>", change_root_to_node, opts("CD"))
	vim.keymap.set("n", "-", change_root_to_parent, opts("Up"))
end
  end,
}
