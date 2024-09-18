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

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- inert new line above/below cursor
keymap.set("n", "gO", "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", { silent = true })
keymap.set("n", "go", "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", { silent = true })

-- diagnostics
keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev)
keymap.set("n", "<leader>dn", vim.diagnostic.goto_next)
keymap.set("n", "<leader>dd", vim.diagnostic.open_float)
keymap.set("n", "<leader>ds", vim.diagnostic.setloclist)

keymap.set("n", "<leader>on", ":ObsidianNew<CR>", { silent = true })
keymap.set("n", "<leader>ot", ":ObsidianNewFromTemplate<CR>", { silent = true })
keymap.set("n", "<leader>oT", ":ObsidianTemplate<CR>", { silent = true })
keymap.set("n", "<leader>ow", ":ObsidianWorkspace<CR>", { silent = true })
keymap.set("n", "<leader>oo", ":ObsidianQuickSwitch<CR>", { silent = true })
keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", { silent = true })
