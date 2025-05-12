local function opts(...)
  local args = { ... }
  if #args == 1 then
    return { desc = args[1], noremap = true, silent = true, nowait = true }
  elseif #args == 2 and type(args[2]) == "table" then
    return {
      desc = args[1],
      noremap = true,
      silent = true,
      nowait = true,
      table.unpack(args[2]),
    }
  end
end
local utils = require("smchunn.core.utils")

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

---------------------
-- General Keymaps
---------------------

-- stylua: ignore start
utils.keymap({
  {"n", "<esc>",      ":nohl<CR>",     opts("Highlight Off")},
  {"n", "x",          '"_x',           opts("Delete char")},
  {"n", "s",          '"_s',           opts("Replace char")},
  {"n", "<leader>+",  "<C-a>",         opts("Number +")},
  {"n", "<leader>-",  "<C-x>",         opts("Number -")},
  {"n", "<leader>sv", "<C-w>v",        opts("Win: v-split")},
  {"n", "<leader>sd", "<C-w>s",        opts("Win: h-split")},
  {"n", "<leader>se", "<C-w>=",        opts("Win: equate")},
  {"n", "<leader>xx", ":close<CR>",    opts("Win: close")},
  {"n", "<leader>sk", "<C-w>k",        opts("Win: move up")},
  {"n", "<leader>sj", "<C-w>j",        opts("Win: move down")},
  {"n", "<leader>sl", "<C-w>l",        opts("Win: move right")},
  {"n", "<leader>sh", "<C-w>h",        opts("Win: move left")},
  {"n", "<leader>sK", "<C-w>+",        opts("Win: expand height")},
  {"n", "<leader>sJ", "<C-w>-",        opts("Win: shrink height")},
  {"n", "<leader>sL", "<C-w>>",        opts("Win: expand width")},
  {"n", "<leader>sH", "<C-w><",        opts("Win: shrink width")},
  {"n", "<leader>to", ":tabnew<CR>",   opts("Tab: new")},
  {"n", "<leader>xt", ":tabclose<CR>", opts("Tab: close")},
  {"n", "<leader>tn", ":tabn<CR>",     opts("Tab: next")},
  {"n", "<leader>tp", ":tabp<CR>",     opts("Tab: prev")},
  {"n", "<leader>p",  "<CTRL>6",       opts("Alternate File")},
  {"n", "<leader>tp", ":tabp<CR>",     opts("Tab: prev")},
  {"n", "gO", "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>", opts("new line above")},
  {"n", "go", "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>", opts("new line below")},
  {"n", "YY", ":%y<CR>",               opts("Copy All")},

  ----------------------
  -- Plugin Keybinds
  ----------------------

  --------------
  -- NvimTree --
  --------------
  {"n", "<leader>e", ":NvimTreeToggle<CR>", opts("Toggle NvimTree")},
  {"n", "<leader>i", function() require("nvim-tree.api").tree.find_file({ open = true, focus = true }) end, opts("Open NvimTree to current buffer")},

  ---------------
  -- Telescope --
  ---------------
  {"n", "<leader>tf",      ":Telescope egrepify<CR>",                                                opts("Telescope Egrepify")},
  {"n", "<leader>f",       function () require("telescope.builtin").find_files() end,                opts("Telescope File Picker")},
  {"n", "<leader>tt",      function () require("telescope.builtin").resume() end,                    opts("Telescope Resume")},
  {"n", "<leader>tr",      function () require("telescope.builtin").pickers() end,                   opts("Telescope Recent Pickers")},
  {"n", "<leader>tc",      function () require("telescope.builtin").filetypes() end,                 opts("Telescope Filetypes")},
  {"n", "<leader>bb",      function () require("telescope.builtin").buffers() end,                   opts("Telescope Buffers")},
  {"n", "<leader>th",      function () require("telescope.builtin").help_tags() end,                 opts("Telescope help")},
  {"n", "<leader>tg",      function () require("telescope.builtin").current_buffer_fuzzy_find() end, opts("Telescope Search Buffer")},
  {"n", "<localleader>gb", function () require("telescope.builtin").git_branches() end,              opts("Teleccope Git Branches")},
  {"n", "<localleader>gc", function () require("telescope.builtin").git_commits() end,               opts("Telescope Git Commits")},
  {"n", "<localleader>gf", function () require("telescope.builtin").git_bcommits() end,              opts("Telescope Git Commits(buffer)")},
  {"n", "<localleader>gs", function () require("telescope.builtin").git_stash() end,                 opts("Telescope Git Stash")},
  {"n", "<localleader>gt", function () require("telescope.builtin").git_status() end,                opts("Telescope Git Status")},
  {"n", "<leader>tz",      ":Telescope spell_suggest<CR>",                                           opts("Telescope Spell Suggest")},

  ---------
  -- lsp --
  ---------
  {"n",          "<leader>rs", ":LspRestart<CR>",                         opts("Restart lsp")},
  { autocmd = "LspAttach", autocmdgroup = "UserLspConfig",
    {"v",          "gf",         vim.lsp.buf.format,                        opts("Format selection")},
    {"n",          "gR",         "<cmd>Telescope lsp_references<CR>",       opts("Show LSP references")},
    {"n",          "gD",         vim.lsp.buf.declaration,                   opts("Go to declaration")},
    {"n",          "gd",         "<cmd>Telescope lsp_definitions<CR>",      opts("Show LSP definitions")},
    {"n",          "gi",         "<cmd>Telescope lsp_implementations<CR>",  opts("Show LSP implementations")},
    {"n",          "gt",         "<cmd>Telescope lsp_type_definitions<CR>", opts("Show LSP type definitions")},
    {{ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action,                   opts("See available code actions")},
    {"n",          "<leader>rn", vim.lsp.buf.rename,                        opts("Smart rename")},
    {"n",          "<leader>D",  "<cmd>Telescope diagnostics bufnr=0<CR>",  opts("Show buffer diagnostics")},
    -- {"n",          "<leader>d",  vim.diagnostic.open_float,                 opts("Show line diagnostics")},
    -- {"n",          "[d",         vim.diagnostic.goto_prev,                  opts("Go to previous diagnostic")},
    -- {"n",          "]d",         vim.diagnostic.goto_next,                  opts("Go to next diagnostic")},
    {"n",          "K",          vim.lsp.buf.hover,                         opts("Show documentation for what is under cursor")},
    {"n",          "<leader>rs", ":LspRestart<CR>",                         opts("Restart LSP")},
  },

  -----------------
  -- Diagnostics --
  -----------------
  {"n", "<leader>dp", vim.diagnostic.goto_prev,  opts("Diagnostics prev")},
  {"n", "<leader>dn", vim.diagnostic.goto_next,  opts("Diagnostics next")},
  {"n", "<leader>dd", vim.diagnostic.open_float, opts("Diagnostics float")},
  {"n", "<leader>ds", vim.diagnostic.setloclist, opts("Diagnostics list")},


  --------------
  -- Obsidian --
  --------------
  -- {"n", "<leader>on", ":ObsidianNew<CR>",             opts("Obsidian New File")},
  -- {"n", "<leader>ot", ":ObsidianNewFromTemplate<CR>", opts("Obsidian New File From Template")},
  -- {"n", "<leader>oT", ":ObsidianTemplate<CR>",        opts("Obsidian New Template")},
  -- {"n", "<leader>ow", ":ObsidianWorkspace<CR>",       opts("Obsidian Switch Workspace")},
  -- {"n", "<leader>oo", ":ObsidianQuickSwitch<CR>",     opts("Obsidian Quick Switch")},
  -- {"n", "<leader>os", ":ObsidianSearch<CR>",          opts("Obsidian Search")},

  ---------------
  -- dashboard --
  ---------------
  {"n", "<leader>db", ":lua Snacks.dashboard.open()<CR>", opts("Open Dashboard")},
})

-- stylua: ignore end
