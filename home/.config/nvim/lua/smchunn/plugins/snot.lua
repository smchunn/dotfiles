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
    { "<leader>nn", "<cmd>NoteNew<cr>", desc = "New note" },
    { "<leader>nf", "<cmd>NoteFind<cr>", desc = "Find note" },
    { "<leader>ns", "<cmd>NoteSearch<cr>", desc = "Search notes" },
    { "<leader>nb", "<cmd>NoteBacklinks<cr>", desc = "Show backlinks" },
    { "<leader>ni", "<cmd>NoteIndex<cr>", desc = "Index vault" },
    { "<leader>nl", "<cmd>NoteLink<cr>", desc = "Insert link" },
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
  ft = "markdown",
}
