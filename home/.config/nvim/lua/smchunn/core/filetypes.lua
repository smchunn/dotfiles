vim.filetype.add({
  extension = {
    jinja = "jinja",
    jinja2 = "jinja",
    j2 = "jinja",
  },
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "markdown",
  callback = function(ev)
    require("smchunn.core.utils").bullets()
    vim.b.last_line_count = vim.api.nvim_buf_line_count(0)

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      buffer = ev.buf,
      callback = function()
        local current_line_count = vim.api.nvim_buf_line_count(0)
        local row = vim.fn.line(".") -- Get the current cursor line
        if
          current_line_count < vim.b.last_line_count
          and (
            string.match(
              vim.api.nvim_buf_get_lines(ev.buf, row - 1, row, false)[1],
              "^%s*%d+%.%s.*$"
            )
            or string.match(
              vim.api.nvim_buf_get_lines(ev.buf, row - 1, row, false)[1],
              "^%s*%d+%.$"
            )
          )
        then
          require("smchunn.core.utils").update_numbered_list(0, row)
        end
        -- Update the last line count
        vim.b.last_line_count = current_line_count
      end,
    })
  end,
})
