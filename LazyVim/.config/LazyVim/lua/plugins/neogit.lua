return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "folke/snacks.nvim",
  },
  keys = require("config.keymaps").neogit,
  opts = {
    integration = {
      diffview = true,
    },
    graph_style = "unicode",
    auto_refresh = true,
    signs = {
      -- { CLOSED, OPENED }
      hunk = { "▸", "▾" },
      item = { "▶", "▼" },
      section = { "▷", "▽" },
    },
    mappings = {
      finder = {
        ["="] = "MultiselectToggleNext",
      },
      status = {
        ["="] = "Toggle",
        ["<space>"] = "Stage",
      },
    },
  },
}
