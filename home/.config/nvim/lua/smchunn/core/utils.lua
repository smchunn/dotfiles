local M = {}

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

function M.keymap(mappings)
  -- Track which augroups we've already cleared in this call
  local cleared_groups = {}

  for _, map in ipairs(mappings) do
    if map.autocmd and map.autocmdgroup then
      -- Clear the augroup only once per call
      local should_clear = not cleared_groups[map.autocmdgroup]
      if should_clear then
        cleared_groups[map.autocmdgroup] = true
      end

      local group = vim.api.nvim_create_augroup(map.autocmdgroup, { clear = should_clear })

      vim.api.nvim_create_autocmd(map.autocmd, {
        group = group,
        callback = function(args)
          local buf = args.buf

          for _, keymap in ipairs(map) do
            local mode = keymap[1]
            local lhs = keymap[2]
            local rhs = keymap[3]
            local opts = keymap[4] or {}

            -- Handle multiple modes (e.g., {"n", "v"})
            if type(mode) == "table" then
              for _, m in ipairs(mode) do
                vim.keymap.set(
                  m,
                  lhs,
                  rhs,
                  vim.tbl_extend("force", opts, { buffer = buf })
                )
              end
            else
              vim.keymap.set(
                mode,
                lhs,
                rhs,
                vim.tbl_extend("force", opts, { buffer = buf })
              )
            end
          end
        end,
      })
    elseif map.autocmd then
      vim.api.nvim_create_autocmd(map.autocmd, {
        callback = function()
          for _, keymap in ipairs(map) do
            vim.api.nvim_set_keymap(keymap[1], keymap[2], keymap[3], keymap[4] or {})
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

local set_cursor_later = vim.schedule_wrap(function(pos)
  vim.api.nvim_win_set_cursor(0, pos)
end)

M.auto_tag = function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  local tag = line:sub(1, col):match("<([%w:%-]+)[^<>]*$")
  if tag == nil then
    return ">"
  end

  set_cursor_later({ row, col + 1 })
  return "></" .. tag .. ">"
end

return M
