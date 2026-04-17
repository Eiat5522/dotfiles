local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import any extras modules here
    { import = "lazyvim.plugins.extras.util.project" },
    { import = "lazyvim.plugins.extras.test.core" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.tailwind" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.linting.eslint" },
    { import = "plugins.extras.edgy" },
    -- import/override with your plugins
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
    },
    {
      "CopilotC-Nvim/CopilotChat.nvim",
      dependencies = {
        { "nvim-lua/plenary.nvim", branch = "master" },
      },
      build = "make tiktoken",
      opts = {},
      -- See Configuration section for options
    },
    {
      "zbirenbaum/copilot.lua",
      md = "Copilot",
      build = ":Copilot auth",
      event = "InsertEnter",
      config = function()
        require("copilot").setup({
          suggestion = {
            auto_trigger = true,
            debounce = 100,
            keymap = {
              accept = "<C-l>",
            },
          },
        })
      end,
    },
    {
      "neovim/nvim-lspconfig",
      opts = {
        servers = {
          marksman = {},
        },
      },
    },
    {
      "iamcco/markdown-preview.nvim",
      cmd = {
        "MarkdownPreviewToggle",
        "MarkdownPreview",
        "MarkdownPreviewStop",
      },
      ft = { "markdown" },
      build = function()
        vim.fn["mkdp#util#install"]()
      end,
    },
    {
      "folke/tokyonight.nvim",
      opts = {
        transparent = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      },
    },
    {
      "folke/lazydev.nvim",
      ft = "lua",
      cmd = "LazyDev",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim.uv" } },
          -- Explicitly add snacks.nvim to the library
          { path = "snacks.nvim", words = { "Snacks" } },
        },
      },
    },
    {
      "akinsho/toggleterm.nvim",
      keys = {
        { "<leader>ft", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
      },
      opts = {
        direction = "float",
        close_on_exit = true,
        persist_mode = true,
        float_opts = {
          border = "rounded",
          width = function()
            return math.floor(vim.o.columns * 0.8)
          end,
          height = function()
            return math.floor(vim.o.lines * 0.7)
          end,
          winblend = 5,
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = { ensure_installed = { "haskell", "ruby" } },
    },
    {
      "nvim-neotest/neotest",
      event = { "BufReadPost", "BufNewFile" },
      dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-jest",
      },
      opts = function(_, opts)
        vim.list_extend(opts.adapters, {
          require("neotest-jest")({
            jestCommand = "pnpm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
        })
      end,
    },
    {
      "mason-org/mason.nvim",
      opts = {
        ensure_installed = {
          "stylua",
          "shfmt",
          "marksman",
          "erb-formatter",
          "erb-lint",
          "ruby-lsp",
        },
      },
    },
    {
      "mason-org/mason-lspconfig.nvim",
      config = function() end,
    },
    {
      "lewis6991/gitsigns.nvim",
      opts = function()
        Snacks.toggle({
          name = "Git Signs",
          get = function()
            return require("gitsigns.config").config.signcolumn
          end,
          set = function(state)
            require("gitsigns").toggle_signs(state)
          end,
        }):map("<leader>uG")
      end,
    },
    {
      "folke/todo-comments.nvim",
      cmd = { "TodoTrouble", "TodoTelescope" },
      event = "LazyFile",
      opts = {},
      -- stylua: ignore
      keys = {
        { "]t",         function() require("todo-comments").jump_next() end,              desc = "Next Todo Comment" },
        { "[t",         function() require("todo-comments").jump_prev() end,              desc = "Previous Todo Comment" },
        { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                                   desc = "Todo (Trouble)" },
        { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
        { "<leader>st", "<cmd>TodoTelescope<cr>",                                         desc = "Todo" },
        { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",                 desc = "Todo/Fix/Fixme" },
      },
    },
    {
      "nvim-mini/mini.ai",
      event = "VeryLazy",
      opts = function()
        local ai = require("mini.ai")
        return {
          n_lines = 500,
          custom_textobjects = {
            o = ai.gen_spec.treesitter({ -- code block
              a = { "@block.outer", "@conditional.outer", "@loop.outer" },
              i = { "@block.inner", "@conditional.inner", "@loop.inner" },
            }),
            f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
            c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
            t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
            d = { "%f[%d]%d+" }, -- digits
            e = { -- Word with case
              { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
              "^().*()$",
            },
            g = { "%", "^.-\z", "$" }, -- buffer
            u = ai.gen_spec.function_call(), -- u for "Usage"
            U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          },
        }
      end,
      config = function(_, opts)
        require("mini.ai").setup(opts)
        local LazyVim = require("lazyvim")
        local on_load = LazyVim.on_load
          or function(name, fn)
            local Config = require("lazy.core.config")
            if Config.plugins[name] and Config.plugins[name]._.loaded then
              fn(name)
            else
              vim.api.nvim_create_autocmd("User", {
                pattern = "LazyLoad",
                callback = function(event)
                  if event.data == name then
                    fn(name)
                    return true
                  end
                end,
              })
            end
          end
        on_load("which-key.nvim", function()
          vim.schedule(function()
            if LazyVim.mini and LazyVim.mini.ai_whichkey then
              LazyVim.mini.ai_whichkey(opts)
            end
          end)
        end)
      end,
    },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Y e our custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
