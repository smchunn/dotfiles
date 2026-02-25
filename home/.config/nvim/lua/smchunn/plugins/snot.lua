return {
  -- "smchunn/snot.nvim",
  dir = "~/dev/snot.nvim",
  name = "snot.nvim",
  -- enabled = false,
  opts = {
    vault_path = "~/notes",
  },
  keys = {
    { "<leader>/f", "<cmd>SnotFind<cr>", desc = "Search notes" },
  },
  -- Optional: define keymaps
  -- keys = {
  --   { "<leader>/n", "<cmd>NoteNew<cr>", desc = "New note" },
  --   { "<leader>/f", "<cmd>NoteFind<cr>", desc = "Find note" },
  --   { "<leader>/s", "<cmd>NoteSearch<cr>", desc = "Search notes" },
  --   { "<leader>/b", "<cmd>NoteBacklinks<cr>", desc = "Show backlinks" },
  --   { "<leader>/i", "<cmd>NoteIndex<cr>", desc = "Index vault" },
  --   { "<leader>/l", "<cmd>NoteLink<cr>", desc = "Insert link" },
  -- },
  -- -- Optional: lazy load on commands or filetypes
  -- cmd = {
  --   "NoteNew",
  --   "NoteFind",
  --   "NoteSearch",
  --   "NoteBacklinks",
  --   "NoteIndex",
  --   "NoteInit",
  --   "NoteLink",
  -- },
}
