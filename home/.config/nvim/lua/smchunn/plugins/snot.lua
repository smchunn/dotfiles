return {
  dir = "~/dev/snot/nvim", -- path to where you cloned the repo
  name = "snot",
  opts = {
    vault_path = "~/snotes/", -- supports ~ home expansion
    snot_bin = "snot", -- or full path like "/usr/local/bin/snot"
    enable_completion = true, -- optional, default: true
    picker = "auto", -- "auto", "fzf-lua", "telescope", or "select" (default: "auto")
  },
  -- Optional: define keymaps
  keys = {
    { "<leader>/n", "<cmd>NoteNew<cr>", desc = "New note" },
    { "<leader>/f", "<cmd>NoteFind<cr>", desc = "Find note" },
    { "<leader>/s", "<cmd>NoteSearch<cr>", desc = "Search notes" },
    { "<leader>/b", "<cmd>NoteBacklinks<cr>", desc = "Show backlinks" },
    { "<leader>/i", "<cmd>NoteIndex<cr>", desc = "Index vault" },
    { "<leader>/l", "<cmd>NoteLink<cr>", desc = "Insert link" },
  },
  -- Optional: lazy load on commands or filetypes
  cmd = {
    "NoteNew",
    "NoteFind",
    "NoteSearch",
    "NoteBacklinks",
    "NoteIndex",
    "NoteInit",
    "NoteLink",
  },
}
