return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "haydenmeade/neotest-jest",
      "thenbe/neotest-playwright",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      if vim.islist(opts.adapters) then
        table.insert(opts.adapters, require("neotest-jest")())
        table.insert(
          opts.adapters,
          require("neotest-playwright").adapter({
            options = {
              persist_project_selection = true,
              enable_dynamic_test_discovery = true,
            },
          })
        )
      else
        opts.adapters["neotest-jest"] = opts.adapters["neotest-jest"] or {}
        opts.adapters["neotest-playwright"] = opts.adapters["neotest-playwright"] or {}
      end
    end,
  },
}
