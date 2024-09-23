local M = {}

function M.file_picker()
  local builtin = require("telescope.builtin")
  if vim.fn.isdirectory(".git") == 1 or vim.fn.filereadable(".git") == 1 then
    builtin.git_files({ show_untracked = true })
  else
    builtin.find_files({ hidden = true })
  end
end

return M
