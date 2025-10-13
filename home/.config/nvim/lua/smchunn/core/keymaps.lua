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
  {"n", "<leader>tx", ":tabclose<CR>", opts("Tab: close")},
  {"n", "<leader>tn", ":tabn<CR>",     opts("Tab: next")},
  {"n", "<leader>tp", ":tabp<CR>",     opts("Tab: prev")},
  {"n", "<leader>p",  "<C-6>",         opts("Alternate File")},
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

  ---------
  -- lsp --
  ---------
  {"n",          "<leader>rs", ":LspRestart<CR>",                    opts("Restart lsp")},
  { autocmd = "LspAttach", autocmdgroup = "UserLspConfig",
    {"v",          "gF", vim.lsp.buf.format,                 opts("Format selection")},
    {"n",          "gr", ":FzfLua lsp_references<CR>",       opts("Show references")},
    {"n",          "gd", ":FzfLua lsp_definitions<CR>",      opts("Show definitions")},
    {"n",          "gi", ":FzfLua lsp_implementations<CR>",  opts("Show implementations")},
    {"n",          "gt", ":FzfLua lsp_type_definitions<CR>", opts("Show type definitions")},
    {{ "n", "v" }, "ga", ":FzfLua lsp_code_actions<CR>",     opts("See available code actions")},
    {"n",          "gn", vim.lsp.buf.rename,                 opts("Smart rename")},
    {"n",          "K",  vim.lsp.buf.hover,                  opts("Show documentation for what is under cursor")},
  },

  -----------------
  -- Diagnostics --
  -----------------
  {"n", "<leader>dp", function() vim.diagnostic.jump({count=-1,float=true}) end, opts("Diagnostics prev")},
  {"n", "<leader>dn", function() vim.diagnostic.jump({count=1,float=true}) end,  opts("Diagnostics next")},
  {"n", "<leader>dt", vim.diagnostic.open_float,                                 opts("Diagnostics float")},
  {"n", "<leader>ds", vim.diagnostic.setloclist,                                 opts("Diagnostics list")},
  {"n", "<leader>dd", ":FzfLua diagnostics_document<CR>",                        opts("Document Diagnostics")},
  {"n", "<leader>dw", ":FzfLua diagnostics_workspace<CR>",                       opts("Workspace Diagnostics")},


  --------------
  -- Obsidian --
  --------------
  {"n", "<leader>on", ":Obsidian new<CR>",             opts("Obsidian New File")},
  -- {"n", "<leader>ot", ":ObsidianNewFromTemplate<CR>", opts("Obsidian New File From Template")},
  -- {"n", "<leader>oT", ":ObsidianTemplate<CR>",        opts("Obsidian New Template")},
  -- {"n", "<leader>ow", ":ObsidianWorkspace<CR>",       opts("Obsidian Switch Workspace")},
  {"n", "<leader>oo", ":Obsidian quick_switch<CR>",     opts("Obsidian Quick Switch")},
  {"n", "<leader>os", ":Obsidian search<CR>",          opts("Obsidian Search")},

  ---------------
  -- dashboard --
  ---------------
  {"n", "<leader>hh", ":lua Snacks.dashboard.open()<CR>", opts("Open Dashboard")},

  ---------------
  --  autotag  --
  ---------------
  {"i", ">", utils.auto_tag, { expr = true }},

})

-- stylua: ignore end
