local keymap = vim.keymap -- for conciseness

local function opts(desc)
  return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---------------------
-- General Keymaps
---------------------

-- clear search highlights
keymap.set("n", "<esc>", ":nohl<CR>", opts("Highlight Off"))

-- delete single character without copying into register
keymap.set("n", "x", '"_x', opts(""))

-- replace single character without copying into register
keymap.set("n", "s", '"_s', opts(""))

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", opts("Number +")) -- increment
keymap.set("n", "<leader>-", "<C-x>", opts("Number -")) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", opts("v-split pane"))     -- split window vertically
keymap.set("n", "<leader>sd", "<C-w>s", opts("h-split pane"))     -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", opts("equate pane"))      -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>", opts("close pane"))   -- close current split window
keymap.set("n", "<leader>sk", "<C-w>k", opts("move up"))          -- move window up
keymap.set("n", "<leader>sj", "<C-w>j", opts("move down"))        -- move window down
keymap.set("n", "<leader>sl", "<C-w>l", opts("move right"))       -- move window right
keymap.set("n", "<leader>sh", "<C-w>h", opts("move left"))        -- move window left
keymap.set("n", "<leader>sK", "<C-w>+", opts("expand height"))    -- expand h
keymap.set("n", "<leader>sJ", "<C-w>-", opts("shrink height"))    -- shrink h
keymap.set("n", "<leader>sL", "<C-w>>", opts("expand width"))     -- expand w
keymap.set("n", "<leader>sH", "<C-w><", opts("shrink width"))     -- shrink w

keymap.set("n", "<leader>to", ":tabnew<CR>", opts("new tab"))     -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>", opts("close tab")) -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>", opts("next tab"))      --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>", opts("prev tab"))      --  go to previous tab

----------------------
-- Plugin Keybinds
----------------------

-- nvim-tree
keymap.set("", "<leader>e", ":NvimTreeToggle<CR>", opts("")) -- toggle file explorer
keymap.set("n", "<C-s>", function() require("nvim-tree.api").tree.find_file({ open = true, focus = true }) end,
  opts("expand tree to current buffer"))


-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts("")) -- mapping to restart lsp if necessary

-- inert new line above/below cursor
keymap.set("n", "gO", "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", opts("new line above"))
keymap.set("n", "go", "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", opts("new line below"))

-- diagnostics
keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts("diagnostics prev"))
keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts("diagnostics next"))
keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts("diagnostics float"))
keymap.set("n", "<leader>ds", vim.diagnostic.setloclist, opts("diagnostics list"))

-- obsidian
keymap.set("n", "<leader>on", ":ObsidianNew<CR>", opts("Obsidian New File"))
keymap.set("n", "<leader>ot", ":ObsidianNewFromTemplate<CR>", opts("Obsidian New File From Template"))
keymap.set("n", "<leader>oT", ":ObsidianTemplate<CR>", opts("Obsidian New Template"))
keymap.set("n", "<leader>ow", ":ObsidianWorkspace<CR>", opts("Obsidian Switch Workspace"))
keymap.set("n", "<leader>oo", ":ObsidianQuickSwitch<CR>", opts("Obsidian Quick Switch"))
keymap.set("n", "<leader>os", ":ObsidianSearch<CR>", opts("Obsidian Search"))
-- dashboard
keymap.set("n", "<leader>db", ":Dashboard<CR>", opts("dashboard"))

-- keymap.set("", "<C-r>", function()
--   local current_buf = vim.api.nvim_get_current_buf()
--   print("current buffer type: " .. vim.bo[current_buf].filetype)
-- end)
