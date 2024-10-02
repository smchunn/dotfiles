return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    -- local moonfly_theme = require("lualine.themes.moonlfy")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- new colors for theme
    local moonfly_colors = {
      Background = "#080808",
      Foreground = "#bdbdbd",
      Bold = "#eeeeee",
      Cursor = "#9e9e9e",
      CursorText = "#808080",
      Selection = "#b2ceee",
      SelectionText = "#808080",
      Black = "#323437",
      Red = "#ff5454",
      Green = "#8cc85f",
      Yellow = "#e3c78a",
      Blue = "#80a0ff",
      Purple = "#cf87e8",
      Cyan = "#79dac8",
      White = "#c6c6c6",
      bBlack = "#949494",
      bRed = "#ff5189",
      bGreen = "#36c692",
      bYellow = "#c2c292",
      bBlue = "#74b2ff",
      bPurple = "#ae81ff",
      bCyan = "#85dc85",
      bWhite = "#e4e4e4",
      uStatusForeground = "#1c1c1c",
      uBackground = "#303030",
    }

    local moonfly_theme = {
      normal = {
        a = { fg = moonfly_colors.uStatusForeground, bg = moonfly_colors.Blue, gui = "bold" },
        b = { fg = moonfly_colors.White, bg = moonfly_colors.uBackground },
        c = { fg = moonfly_colors.White, bg = moonfly_colors.uBackground },
      },
      insert = {
        a = { fg = moonfly_colors.uStatusForeground, bg = moonfly_colors.Green, gui = "bold" },
        b = { fg = moonfly_colors.White, bg = moonfly_colors.uBackground },
      },
      visual = {
        a = { fg = moonfly_colors.uStatusForeground, bg = moonfly_colors.bPurple, gui = "bold" },
        b = { fg = moonfly_colors.White, bg = moonfly_colors.uBackground },
      },
      command = {
        a = { bg = moonfly_colors.Yellow, fg = moonfly_colors.uStatusForeground, gui = "bold" },
      },
      replace = {
        a = { fg = moonfly_colors.uStatusForeground, bg = moonfly_colors.bRed, gui = "bold" },
        b = { fg = moonfly_colors.White, bg = moonfly_colors.uBackground },
      },
      inactive = {
        a = { fg = moonfly_colors.Cursor, bg = moonfly_colors.uBackground, gui = "bold" },
        b = { fg = moonfly_colors.Cursor, bg = moonfly_colors.uBackground },
        c = { fg = moonfly_colors.Cursor, bg = moonfly_colors.uBackground },
      },
    }

    lualine.setup({
      options = {
        theme = moonfly_theme,
        disabled_filetypes = { "NvimTree" },
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
    })
  end,
}
