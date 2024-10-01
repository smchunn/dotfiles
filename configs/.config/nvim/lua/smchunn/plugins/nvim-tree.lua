-- local HEIGHT_RATIO = 0.8
-- local WIDTH_RATIO = 0.5
local HEIGHT_RATIO = 0.9
local WIDTH_RATIO = 0.9

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

local function nvim_tree_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  local function change_root_to_node(node)
    if node == nil then
      node = api.tree.get_node_under_cursor()
    end

    if node ~= nil and node.type == "directory" then
      vim.api.nvim_set_current_dir(node.absolute_path)
    end
    api.tree.change_root_to_node(node)
  end

  local function change_root_to_parent(node)
    local abs_path
    if node == nil then
      abs_path = api.tree.get_nodes().absolute_path
    else
      abs_path = node.absolute_path
    end

    local parent_path = vim.fs.dirname(abs_path)
    vim.api.nvim_set_current_dir(parent_path)
    api.tree.change_root(parent_path)
  end

  vim.keymap.set("n", "<C-]>", change_root_to_node, opts("CD"))
  vim.keymap.set("n", "-", change_root_to_parent, opts("Up"))
  vim.keymap.set("n", "<esc>", api.tree.close, opts("Close tree"))
end

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {
    update_cwd = true,
    renderer = {
      icons = {
        glyphs = {
          folder = {
            arrow_closed = "󰧂",
            arrow_open = "󰦺",
          },
        },
      },
    },
    actions = {
      open_file = {
        window_picker = {
          enable = false,
        },
      },
    },
    hijack_directories = {
      enable = false,
    },
    view = {
      float = {
        enable = true,
        open_win_config = function()
          local screen_w = vim.opt.columns:get()
          local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
          local window_w = screen_w * WIDTH_RATIO
          local window_h = screen_h * HEIGHT_RATIO
          local window_w_int = math.floor(window_w)
          local window_h_int = math.floor(window_h)
          local center_x = (screen_w - window_w) / 2
          local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()
          return {
            border = "rounded",
            relative = "editor",
            row = center_y,
            col = center_x,
            width = window_w_int,
            height = window_h_int,
          }
        end,
      },
      width = function()
        return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
      end,
    },
    on_attach = nvim_tree_on_attach,
  },
}
