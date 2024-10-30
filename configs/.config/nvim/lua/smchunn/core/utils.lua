local M = { actions = {}, previewers = {} }

local function get_row(buf, row)
  return vim.api.nvim_buf_get_lines(buf, row - 1, row, false)[1]
end

function M.dump(o)
  if type(o) == "table" then
    local s = "{ "
    for k, v in pairs(o) do
      s = s .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end
    return s .. "} "
  else
    return tostring(o)
  end
end

function M.opts(...)
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

function M.actions.git_apply_stash_file(stash_id)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  return function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selection = picker:get_multi_selection()
    if #selection == 0 then
      selection = { picker:get_selection() }
    end

    local files = {}
    for _, sel in ipairs(selection) do
      table.insert(files, sel[1])
    end
    local git_command = {
      "sh",
      "-c",
      "git --no-pager diff HEAD.." .. " | git apply -",
    }

    local _, ret, stderr = M.get_os_command_output(git_command)
    if ret == 0 then
      print("Applied stash files from " .. stash_id)
    else
      print("Error applying stash " .. vim.inspect(stderr))
    end
    actions.close(prompt_bufnr)
  end
end

function M.actions.show_git_stash_files()
  local actions = require("telescope.actions")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local action_state = require("telescope.actions.state")
  local telescope_config = require("telescope.config").values

  local selection = action_state.get_selected_entry()
  if selection == nil or selection.value == nil or selection.value == "" then
    return
  end

  local stash_id = selection.value

  local opts = {}
  local p = pickers.new(opts, {
    prompt_title = "Files in " .. stash_id,
    finder = finders.new_oneshot_job({
      "git",
      "--no-pager",
      "stash",
      "show",
      stash_id,
      "--name-only",
    }, opts),
    previewer = M.previewers.git_stash_file(stash_id, opts),
    sorter = telescope_config.file_sorter(opts),
    attach_mappings = function()
      actions.select_default:replace(M.actions.git_apply_stash_file(stash_id))
      return true
    end,
  })
  p:find()
end

function M.previewers.git_stash_file(stash_id, opts)
  local previewers = require("telescope.previewers")
  local putils = require("telescope.previewers.utils")

  return previewers.new_buffer_previewer({
    title = "Stash file preview",
    get_buffer_by_name = function(_, entry)
      return entry.value
    end,
    define_preview = function(self, entry, _)
      local cmd = { "git", "--no-pager", "diff", stash_id, "--", entry.value }
      putils.job_maker(cmd, self.state.bufnr, {
        value = entry.value,
        bufname = self.state.bufname,
        cwd = opts.cwd,
        callback = function(bufnr)
          if vim.api.nvim_buf_is_valid(bufnr) then
            putils.regex_highlighter(bufnr, "diff")
          end
        end,
      })
    end,
  })
end

function M.actions.open_and_resume(prompt_bufnr)
  require("telescope.actions").select_default(prompt_bufnr)
  require("telescope.builtin").resume()
end

function M.actions.open_in_nvim_tree(prompt_bufnr)
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local nvim_tree_api = require("nvim-tree.api")

  local selection = action_state.get_selected_entry()
  if not selection then
    print("No selection made")
    return
  end

  local selection_path = selection.value

  actions.close(prompt_bufnr)

  print("open...")
  nvim_tree_api.tree.open()
  nvim_tree_api.tree.find_file({
    buf = selection_path,
    open = true,
    focus = true,
  })
end

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

function M.keymap(mappings)
  for _, map in ipairs(mappings) do
    if map.autocmd and map.autocmdgroup then
      vim.api.nvim_create_autocmd(map.autocmd, {
        group = vim.api.nvim_create_augroup(map.autocmdgroup, {}),
        callback = function(args)
          local buf = args.buf
          for _, keymap in ipairs(map) do
            vim.keymap.set(
              keymap[1],
              keymap[2],
              keymap[3],
              vim.tbl_extend("force", keymap[4], { buffer = buf })
            )
          end
        end,
      })
    elseif map.autocmd then
      vim.api.nvim_create_autocmd(map.autocmd, {
        callback = function()
          for _, keymap in ipairs(map) do
            vim.api.nvim_set_keymap(keymap[1], keymap[2], keymap[3], keymap[4])
          end
        end,
      })
    else
      -- Handle regular keymaps
      vim.keymap.set(map[1], map[2], map[3], map[4])
    end
  end
end

local function bullet_insert(mode)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  -- dash
  if
    string.match(get_row(buf, row), "^%s*%-%s.*$")
    or string.match(get_row(buf, row), "^%s*%-$")
  then
    local pre = string.gsub(get_row(buf, row), "%S+.*$", "") .. "- "
    if mode == "insert" then
      if col <= string.len(pre) then
        vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { pre, "" })
        vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      else
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "", pre })
        vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      end
      vim.cmd("startinsert")
    else
      if mode == "above" then
        row = row - 1
      end
      vim.api.nvim_buf_set_lines(0, row, row, false, { pre })
      vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      vim.cmd("startinsert!")
    end
  -- asterisk
  elseif
    string.match(get_row(buf, row), "^%s**%s.*$")
    or string.match(get_row(buf, row), "^%s*%*$")
  then
    local pre = string.gsub(get_row(buf, row), "%S+.*$", "") .. "* "
    if mode == "insert" then
      if col <= string.len(pre) then
        vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { pre, "" })
        vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      else
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "", pre })
        vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      end
      vim.cmd("startinsert")
    else
      if mode == "above" then
        row = row - 1
      end
      vim.api.nvim_buf_set_lines(0, row, row, false, { pre })
      vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      vim.cmd("startinsert!")
    end
  -- number
  elseif
    string.match(get_row(buf, row), "^%s*%d+%.%s.*$")
    or string.match(get_row(buf, row), "^%s*%d+%.$")
  then
    -- stylua: ignore
    local num, _ = string.gsub(string.gsub(get_row(buf, row), "^%s*", ""), "%..*$", "")
    local new_num = tonumber(num) + 1 or 1
    local indent = string.match(get_row(buf, row), "^%s*%s%s")
    print(indent)
    -- stylua: ignore
    local pre = string.gsub(get_row(buf, row), "%d+%..*$", "") .. new_num .. ". "
    if mode == "insert" then
      if col <= string.len(pre) then
        vim.api.nvim_buf_set_text(0, row - 1, 0, row - 1, 0, { pre, "" })
        vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      else
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "", pre })
        vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      end
      M.update_numbered_list(vim.api.nvim_get_current_buf(), row)
      vim.cmd("startinsert")
    else
      if mode == "above" then
        row = row - 1
      end
      vim.api.nvim_buf_set_lines(0, row, row, false, { pre })
      vim.api.nvim_win_set_cursor(0, { row + 1, string.len(pre) })
      M.update_numbered_list(vim.api.nvim_get_current_buf(), row)
      vim.cmd("startinsert!")
    end
  else
    local indent = string.match(get_row(buf, row), "^%s*") or ""
    if mode == "insert" then
      -- Insert a new line with the same indentation
      vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "", indent })
      vim.api.nvim_win_set_cursor(0, { row + 1, col })
      vim.cmd("startinsert")
    else
      if mode == "above" then
        row = row - 1
      end
      -- Insert a new line with the same indentation
      vim.api.nvim_buf_set_lines(0, row, row, false, { indent })
      vim.api.nvim_win_set_cursor(0, { row + 1, string.len(indent) })
      vim.cmd("startinsert!")
    end
    return false
  end
  return true
end

local function bullet_delete()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  if string.match(get_row(buf, row), "^%s*%-%s*$") then
    vim.api.nvim_buf_set_lines(buf, row - 1, row, false, { "" })
    return true
  end
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<BS>", true, false, true),
    "n",
    false
  )
  return false
end

local function bullet_indent(detab)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local buf = vim.api.nvim_get_current_buf()
  if string.match(get_row(buf, row), "^%s*%-%s*$") then
    if not detab then
      vim.cmd("normal >>")
    else
      vim.cmd("normal <<")
    end
    vim.cmd("startinsert!")
    return true
  end
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<TAB>", true, false, true),
    "n",
    false
  )
  return false
end

local function map_with_fallback(mode, lhs, condition_func)
  local original_mapping = vim.api.nvim_get_keymap(mode)

  local default_key = nil
  for _, mapping in ipairs(original_mapping) do
    if mapping.lhs == lhs then
      default_key = mapping.rhs
      break
    end
  end

  vim.keymap.set(
    mode,
    lhs,
    function()
      if not condition_func() then
        if default_key then
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(default_key, true, false, true),
            "n", -- Use 'n' for noremap mode or adjust as needed
            true
          )
        end
      end
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
end

function M.bullets(opts)
  vim.keymap.set(
    "n",
    "o",
    function()
      return bullet_insert("below")
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
  vim.keymap.set(
    "n",
    "O",
    function()
      return bullet_insert("above")
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
  vim.keymap.set(
    "i",
    "<CR>",
    function()
      return bullet_insert("insert")
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
  vim.keymap.set(
    "i",
    "<BS>",
    function()
      return bullet_delete()
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
  vim.keymap.set(
    "i",
    "<TAB>",
    function()
      return bullet_indent(false)
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
  vim.keymap.set(
    "i",
    "<S-TAB>",
    function()
      return bullet_indent(true)
    end,
    { buffer = vim.api.nvim_get_current_buf(), nowait = true, silent = true }
  )
  local CleanOnSaveBullet = vim.api.nvim_create_augroup("CleanOnSaveBullet", {})
  vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    group = CleanOnSaveBullet,
    pattern = "*.md",
    command = [[ %s/^\s*\(\-\|\*\|\d*\.\)\s*$//e]],
  })
end

function M.update_numbered_list(buf, row)
  local new_num = 1

  if true then
    while
      string.match(get_row(buf, row - 1), "^%s*%d+%.%s.*$")
      or string.match(get_row(buf, row - 1), "^%s*%d+%.$")
    do
      row = row - 1
    end
  elseif
    string.match(get_row(buf, row), "^%s*%d+%.%s.*$")
    or string.match(get_row(buf, row), "^%s*%d+%.$")
  then
    local num, _ =
      string.gsub(string.gsub(get_row(buf, row - 1), "^%s*", ""), "%..*$", "")
    new_num = tonumber(num) + 1 or 1
  end

  while
    row <= vim.api.nvim_buf_line_count(buf)
    and (
      string.match(get_row(buf, row), "^%s*%d+%.%s.*$")
      or string.match(get_row(buf, row), "^%s*%d+%.$")
    )
  do
    local new_line = string.gsub(get_row(buf, row), "%S+.*$", "")
      .. new_num
      .. ". "
      .. string.gsub(get_row(buf, row), "^%s*%d+%.%s?", "")
    vim.api.nvim_buf_set_lines(0, row - 1, row, false, { new_line })
    row = row + 1
    new_num = new_num + 1
  end
end

return M
