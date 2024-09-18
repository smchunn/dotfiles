-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end

-- import telescope actions safely
local builtin_setup, builtin = pcall(require, "telescope.builtin")
if not builtin_setup then
	return
end

local M = { actions = {}, previewers = {} }

-- configure telescope
telescope.setup({
	-- configure custom mappings
	defaults = {
		prompt_prefix = " λ ",
		selection_caret = "󰁕 ",
		path_display = { "smart" },
		winblend = 10,
		cache_picker = {
			num_pickers = 10,
		},
		-- layout_strategy = "vertical",
		-- layout_config = {
		-- 	vertical = {
		-- 		preview_height = 0.7,
		-- 		size = {
		-- 			width = "95%",
		-- 			height = "95%",
		-- 		},
		-- 	},
		-- },
		layout_config = {
			width = 0.8,
			prompt_position = "top",
			preview_cutoff = 120,
		},
		color_devicons = true,
		use_less = true,
		mappings = {
			i = {
				["<C-h>"] = actions.select_horizontal,
				["<C-o>"] = M.actions.open_and_resume,
				["<C-p>"] = require("telescope.actions.layout").toggle_preview,
				["<C-s>"] = M.actions.open_in_nvim_tree,
				-- ["<C-k>"] = actions.move_selection_previous, -- move to prev result
				-- ["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
				["<esc>"] = actions.close,
			},
			n = {
				["<C-h>"] = actions.select_horizontal,
				["<C-o>"] = M.actions.open_and_resume,
				["<C-p>"] = require("telescope.actions.layout").toggle_preview,
				["<C-s>"] = M.actions.open_in_nvim_tree,
			},
		},
	},
	pickers = {
		git_stash = {
			mappings = {
				i = {
					["<C-f>"] = M.actions.show_git_stash_files,
				},
			},
		},
		buffers = {
			mappings = {
				i = {
					["<C-d>"] = actions.delete_buffer,
				},
			},
		},
	},
	extensions = {
		egrepify = {},
	},
})

-- Search
vim.keymap.set("n", "<c-f>", "<cmd>Telescope egrepify<cr>", { silent = true })

-- Fuzzy file finder
if vim.fn.isdirectory(".git") == 1 or vim.fn.filereadable(".git") == 1 then
	vim.keymap.set("n", "<leader>f", function()
		builtin.git_files({
			show_untracked = true,
		})
	end)
else
	vim.keymap.set("n", "<leader>f", function()
		builtin.find_files({
			hidden = true,
		})
	end)
end

-- Resume last telescope search
vim.keymap.set("n", "<leader>rr", builtin.resume)
vim.keymap.set("n", "<leader>rp", builtin.pickers)

-- File type
vim.keymap.set("n", "<leader>cf", builtin.filetypes)

-- Buffers
vim.keymap.set("n", "<leader>bb", builtin.buffers)

-- Help
vim.keymap.set("n", "<localleader>h", builtin.help_tags) -- list available help tags

-- (Ctrl + /) Search inside current buffer
vim.keymap.set("n", "<C-_>", builtin.current_buffer_fuzzy_find)

-- Git
vim.keymap.set("n", "<localleader>gb", builtin.git_branches)
vim.keymap.set("n", "<localleader>gc", builtin.git_commits)
vim.keymap.set("n", "<localleader>gf", builtin.git_bcommits)
vim.keymap.set("n", "<localleader>gs", builtin.git_stash)
vim.keymap.set("n", "<localleader>gt", builtin.git_status)

-- Spell suggestions
vim.keymap.set("n", "z=", ":Telescope spell_suggest<CR>")

function M.actions.git_apply_stash_file(stash_id)
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local utils = require("telescope.utils")

	return function(prompt_bufnr)
		local picker = action_state.get_current_picker(prompt_bufnr)

		local selection = picker:get_multi_selection()
		if #selection == 0 then
			selection = { picker:get_selection() }
		end

		local files = {}
		for _, sel in ipairs(selection) do
			table.insert(files, sel[1])
		end
		local git_command = {
			"sh",
			"-c",
			"git --no-pager diff HEAD.." .. stash_id .. " -- " .. table.concat(files, " ") .. " | git apply -",
		}

		local _, ret, stderr = utils.get_os_command_output(git_command)
		if ret == 0 then
			print("Applied stash files from " .. stash_id)
		else
			print("Error applying stash " .. stash_id .. ": " .. vim.inspect(stderr))
		end
		actions.close(prompt_bufnr)
	end
end

function M.actions.show_git_stash_files()
	local actions = require("telescope.actions")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local action_state = require("telescope.actions.state")
	local telescope_config = require("telescope.config").values

	local selection = action_state.get_selected_entry()
	if selection == nil or selection.value == nil or selection.value == "" then
		return
	end

	local stash_id = selection.value

	local opts = {}
	local p = pickers.new(opts, {
		prompt_title = "Files in " .. stash_id,
		__locations_input = true,
		finder = finders.new_oneshot_job({
			"git",
			"--no-pager",
			"stash",
			"show",
			stash_id,
			"--name-only",
		}, opts),
		previewer = M.previewers.git_stash_file(stash_id, opts),
		sorter = telescope_config.file_sorter(opts),
		attach_mappings = function() -- (_, map)
			actions.select_default:replace(M.actions.git_apply_stash_file(stash_id))
			return true
		end,
	})
	p:find()
end

function M.previewers.git_stash_file(stash_id, opts)
	local putils = require("telescope.previewers.utils")
	local previewers = require("telescope.previewers")

	return previewers.new_buffer_previewer({
		title = "Stash file preview",
		get_buffer_by_name = function(_, entry)
			return entry.value
		end,
		define_preview = function(self, entry, _)
			local cmd = { "git", "--no-pager", "diff", stash_id, "--", entry.value }
			putils.job_maker(cmd, self.state.bufnr, {
				value = entry.value,
				bufname = self.state.bufname,
				cwd = opts.cwd,
				callback = function(bufnr)
					if vim.api.nvim_buf_is_valid(bufnr) then
						putils.regex_highlighter(bufnr, "diff")
					end
				end,
			})
		end,
	})
end

function M.actions.open_and_resume(prompt_bufnr)
	require("telescope.actions").select_default(prompt_bufnr)
	require("telescope.builtin").resume()
end

function M.actions.open_in_nvim_tree(prompt_bufnr)
	local action_state = require("telescope.actions.state")
	local actions = require("telescope.actions")
	local nvim_tree_api = require("nvim-tree.api")

	-- Get the selected entry
	local selection = action_state.get_selected_entry()
	if not selection then
		print("No selection made")
		return
	end

	-- Get the path of the selected entry
	local selection_path = selection.value

	-- Close the Telescope prompt
	actions.close(prompt_bufnr)

	-- Open the selected file or directory in Nvim Tree
	nvim_tree_api.tree.open()
	nvim_tree_api.tree.find_file({ buf = selection_path, open = true })
end

telescope.load_extension("fzf")
