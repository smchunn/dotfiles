-- Function to set options for the dashboard
local function set_dashboard_options()
  local current_buf = vim.api.nvim_get_current_buf()
  -- print("current buffer type: " .. vim.bo[current_buf].filetype)
  if
    vim.bo[current_buf].filetype ~= "snacks_dashboard"
    and vim.bo[current_buf].filetype ~= "TelescopePrompt"
    and vim.bo[current_buf].filetype ~= "TelescopeResults"
    and vim.bo[current_buf].filetype ~= "NvimTree"
  then
    -- print("unset")
    vim.opt.mouse = vim.d_mouse
    vim.opt.fillchars = vim.d_fillchars
  -- vim.api.nvim_set_hl(0, "Cursor", { blend = 0, force = true })
  else
    -- print("set")
    vim.opt.mouse = ""
    vim.opt.fillchars = { eob = " " }
    -- vim.api.nvim_set_hl(0, "Cursor", { blend = 100, force = true})
  end
end

-- Set up the FileType autocommand for dashboard
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  pattern = "*",
  callback = set_dashboard_options,
})

-- remove trailing whitespace from all lines before saving a file
local CleanOnSave = vim.api.nvim_create_augroup("CleanOnSave", {})
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = CleanOnSave,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- autocmd to open dashboard when open to dir
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  callback = function(opts)
    -- vim.d_guicursor = vim.o.guicursor
    vim.d_mouse = vim.opt.mouse
    vim.d_fillchars = { eob = "~" }

    -- buffer is a [No Name]
    local no_name = opts.file == "" and vim.bo[opts.buf].buftype == ""

    -- buffer is a directory
    local directory = vim.fn.isdirectory(opts.file) == 1

    if not no_name and not directory then
      return
    end

    -- change to the directory
    if directory then
      vim.cmd.cd(opts.file)
      Snacks.dashboard()
    end
  end,
})
