-- Function to set options for the dashboard
local function set_dashboard_options()
  local current_buf = vim.api.nvim_get_current_buf()
  print("current buffer type: " .. vim.bo[current_buf].filetype)
  if vim.bo[current_buf].filetype ~= "TelescopePrompt"
      and vim.bo[current_buf].filetype ~= "TelescopeResults"
      and vim.bo[current_buf].filetype ~= "dashboard"
      and vim.bo[current_buf].filetype ~= "dashboard"
  then
    print("scroll on")
    vim.opt_local.scrolloff = 0
    vim.opt.mouse = "a"
    vim.opt_local.fillchars = { eob = "~" }
  else
    print("scroll off")
    vim.opt_local.scrolloff = 999
    vim.opt_local.mouse = ""
    vim.opt_local.fillchars = { eob = " " }
  end
end

-- Set up the FileType autocommand for dashboard
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dashboard",
  callback = function()
    set_dashboard_options()

    -- Create a BufEnter autocommand to reset options when entering a different buffer
    local buf_enter_id = vim.api.nvim_create_autocmd("BufEnter", {
      callback = set_dashboard_options,
    })

    -- Create a BufDelete autocommand to remove the BufEnter autocommand when the dashboard buffer is deleted
    -- vim.api.nvim_create_autocmd("BufDelete", {
    --   buffer = 0,                              -- This refers to the current buffer (dashboard)
    --   callback = function()
    --     vim.api.nvim_del_autocmd(buf_enter_id) -- Remove the BufEnter autocommand
    --   end,
    -- })
  end,
})
