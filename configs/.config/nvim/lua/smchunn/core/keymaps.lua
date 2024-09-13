local keymap = vim.keymap -- for conciseness

-- set leader key to space
vim.g.mapleader = " "

---------------------
-- General Keymaps
---------------------

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { silent = true })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- replace single character without copying into register
keymap.set("n", "s", '"_s')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sd", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window
keymap.set("n", "<leader>sk", "<C-w>k") -- move window up
keymap.set("n", "<leader>sj", "<C-w>j") -- move window down
keymap.set("n", "<leader>sl", "<C-w>l") -- move window right
keymap.set("n", "<leader>sh", "<C-w>h") -- move window left
keymap.set("n", "<leader>sK", "<C-w>+") -- expand h
keymap.set("n", "<leader>sJ", "<C-w>-") -- shrink h
keymap.set("n", "<leader>sL", "<C-w>>") -- expand w
keymap.set("n", "<leader>sH", "<C-w><") -- shrink w 

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
keymap.set("", "<leader>e", ":NvimTreeToggle<CR>", { silent = true }) -- toggle file explorer

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- inert new line above/below cursor
keymap.set("n", "gO", "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { silent = true })
keymap.set("n", "go", "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", { silent = true })
