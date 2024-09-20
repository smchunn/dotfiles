local keymap = vim.keymap -- for conciseness

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---------------------
-- General Keymaps
---------------------

-- clear search highlights
keymap.set("n", "<esc>", ":nohl<CR>", { desc = "Highlight Off", silent = true, noremap = true })

-- delete single character without copying into register
keymap.set("n", "x", '"_x', { desc = "", silent = true, noremap = true })

-- replace single character without copying into register
keymap.set("n", "s", '"_s', { desc = "", silent = true, noremap = true })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Number +", silent = true, noremap = true }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Number -", silent = true, noremap = true }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "v-split pane", silent = true, noremap = true }) -- split window vertically
keymap.set("n", "<leader>sd", "<C-w>s", { desc = "h-split pane", silent = true, noremap = true }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "equate pane", silent = true, noremap = true }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "close pane", silent = true, noremap = true }) -- close current split window
keymap.set("n", "<leader>sk", "<C-w>k", { desc = "move up", silent = true, noremap = true }) -- move window up
keymap.set("n", "<leader>sj", "<C-w>j", { desc = "move down", silent = true, noremap = true }) -- move window down
keymap.set("n", "<leader>sl", "<C-w>l", { desc = "move right", silent = true, noremap = true }) -- move window right
keymap.set("n", "<leader>sh", "<C-w>h", { desc = "move left", silent = true, noremap = true }) -- move window left
keymap.set("n", "<leader>sK", "<C-w>+", { desc = "expand height", silent = true, noremap = true }) -- expand h
keymap.set("n", "<leader>sJ", "<C-w>-", { desc = "shrink height", silent = true, noremap = true }) -- shrink h
keymap.set("n", "<leader>sL", "<C-w>>", { desc = "expand width", silent = true, noremap = true }) -- expand w
keymap.set("n", "<leader>sH", "<C-w><", { desc = "shrink width", silent = true, noremap = true }) -- shrink w

keymap.set("n", "<leader>to", ":tabnew<CR>", { desc = "new tab", silent = true, noremap = true }) -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>", { desc = "close tab", silent = true, noremap = true }) -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>", { desc = "next tab", silent = true, noremap = true }) --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>", { desc = "prev tab", silent = true, noremap = true }) --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- nvim-tree
keymap.set("", "<leader>e", ":NvimTreeToggle<CR>", { desc = "", silent = true, noremap = true }) -- toggle file explorer

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>", { desc = "", silent = true, noremap = true }) -- mapping to restart lsp if necessary

-- inert new line above/below cursor
keymap.set(
	"n",
	"gO",
	"<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>",
	{ desc = "new line above", silent = true, noremap = true }
)
keymap.set(
	"n",
	"go",
	"<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>",
	{ desc = "new line below", silent = true, noremap = true }
)

-- diagnostics
keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { desc = "diagnostics prev", silent = true, noremap = true })
keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { desc = "diagnostics next", silent = true, noremap = true })
keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "diagnostics float", silent = true, noremap = true })
keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "diagnostics list", silent = true, noremap = true })

keymap.set("n", "<leader>on", ":ObsidianNew<CR>", { desc = "Obsidian New File", silent = true, noremap = true })
keymap.set(
	"n",
	"<leader>ot",
	":ObsidianNewFromTemplate<CR>",
	{ desc = "Obsidian New File From Template", silent = true, noremap = true }
)
keymap.set(
	"n",
	"<leader>oT",
	":ObsidianTemplate<CR>",
	{ desc = "Obsidian New Template", silent = true, noremap = true }
)
keymap.set(
	"n",
	"<leader>ow",
	":ObsidianWorkspace<CR>",
	{ desc = "Obsidian Switch Workspace", silent = true, noremap = true }
)
keymap.set(
	"n",
	"<leader>oo",
	":ObsidianQuickSwitch<CR>",
	{ desc = "Obsidian Quick Switch", silent = true, noremap = true }
)
keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", { desc = "Obsidian Search", silent = true, noremap = true })
