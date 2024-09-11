
local setup, obsidian = pcall(require, "obsidian")
if not setup then
  return
end

-- enable obsidian
obsidian.setup({
  workspaces = {
    {
      name = "work",
      path = "~/Library/CloudStorage/OneDrive-MMC/Documents/vaults/work",
    },
  },
  ui = {
    enable = false,
  }
})
