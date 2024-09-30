local M = {}

function M.file_picker()
  local builtin = require("telescope.builtin")
  if vim.fn.isdirectory(".git") == 1 or vim.fn.filereadable(".git") == 1 then
    builtin.git_files({ show_untracked = true })
  else
    builtin.find_files({ hidden = true })
  end
end

function M.open_in_nvim_tree()
  local nvim_tree_api = require("nvim-tree.api")

  print("open...")
  nvim_tree_api.tree.find_file({ open = true })
end

return M
