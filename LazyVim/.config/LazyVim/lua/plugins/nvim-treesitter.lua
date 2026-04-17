---@diagnostic disable: undefined-global, missing-fields

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    local install_dir = vim.g.pre_install_root .. "/treesitter"
    vim.opt.runtimepath:append(install_dir)

    require("nvim-treesitter.configs").setup({
      parser_install_dir = install_dir,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      prefer_git = true,
      textobjects = { select = { enable = true, lookahead = true } },
    })
  end,
}
