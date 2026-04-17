--- @diagnostic disable: undefined-global

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  keys = require("config.keymaps").snacks,
  opts = {
    bigfile = { enabled = true },
    explorer = { enabled = true },
    rename = { enabled = true },
    input = {
      enabled = true,
    },
    notifier = {
      enabled = true,
      margin = { top = 0, right = 1, bottom = 2 },
      style = "minimal",
      top_down = false,
    },
    picker = {
      filter = {
        cwd = true,
      },
      formatters = {
        file = {
          filename_first = true,
          truncate = 70,
        },
      },
      layout = {
        cycle = true,
      },
      sources = {
        explorer = {
          auto_close = true,
        },
        projects = {
          confirm = function(picker, item)
            picker:close()
            -- Change the working directory to the selected project
            vim.cmd("cd " .. vim.fn.fnameescape(item.path))
            -- Notify the user that the directory has changed
            vim.notify("Changed directory to: " .. item.path, vim.log.levels.INFO)
          end,
        },
      },
    },
    indent = {
      animate = { enabled = false },
      indent = {
        enabled = false,
      },
      scope = {
        hl = "CursorLineSign",
      },
      chunk = {
        enabled = true,
        char = {
          -- corner_top = "┌",
          -- corner_bottom = "└",
          corner_top = "╭",
          corner_bottom = "╰",
          horizontal = "─",
          vertical = "❘",
          arrow = "",
        },
        hl = "CursorLineSign",
      },
    },
    lazygit = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    dashboard = {
      enabled = true,
    },
    styles = {
      notification_history = {
        relative = "editor",
      },
      input = {
        relative = "cursor",
        row = 1,
        keys = {
          ["<c-c>"] = { "close", mode = { "n", "i" } },
        },
      },
      terminal = {
        keys = {
          term_put = {
            "<m-p>",
            function()
              vim.cmd("stopinsert")
              vim.schedule(function()
                vim.cmd("normal! p")
                vim.cmd("startinsert")
              end)
            end,
            mode = "t",
            desc = "Paste into terminal",
          },
        },
      },
    },
  },
  init = function()
    -- Create Lazygit command
    vim.api.nvim_create_user_command("Lazygit", function()
      local Snacks = require("snacks")
      Snacks.lazygit()
    end, {
      desc = "Open Lazygit in a Snacks terminal",
    })

    -- Create SnacksPicker command
    vim.api.nvim_create_user_command("Picker", function(cmdargs)
      local Snacks = require("snacks")
      local picker = Snacks.picker
      local args = vim.split(cmdargs.args, "%s+")
      if #args == 0 then
        picker.open()
        return
      end
      local picker_name = table.remove(args, 1)
      if picker[picker_name] then
        picker[picker_name](unpack(args))
      else
        vim.notify("No such Snacks picker: " .. picker_name, vim.log.levels.ERROR)
      end
    end, {
      nargs = "*",
      desc = "Launch Snacks pickers",
      complete = function(arg_lead, cmd_line, cursor_pos)
        local Snacks = require("snacks")
        local picker = Snacks.picker
        local pickers = {}

        -- Collect all picker functions
        for name, value in pairs(picker) do
          if type(value) == "function" and not name:match("^_") then
            table.insert(pickers, name)
          end
        end

        -- Filter by the current input
        if arg_lead ~= "" then
          pickers = vim.tbl_filter(function(picker_name)
            return picker_name:find(arg_lead, 1, true) == 1
          end, pickers)
        end

        table.sort(pickers)
        return pickers
      end,
    })

    -- Create Snacks Notification History command
    vim.api.nvim_create_user_command("Notifications", function()
      local Snacks = require("snacks")
      Snacks.notifier.show_history()
    end, {
      desc = "Show Snacks notification history",
    })

    -- Create Snacks Todo command
    vim.api.nvim_create_user_command("Todos", function()
      local Snacks = require("snacks")
      Snacks.picker.todo_comments()
    end, {
      desc = "Show Snacks todo list",
    })

    -- Create Snacks Help command
    vim.api.nvim_create_user_command("Help", function()
      local Snacks = require("snacks")
      Snacks.picker.help()
    end, {
      desc = "Show Snacks help",
    })

    -- Create Snacks Commands command
    vim.api.nvim_create_user_command("Commands", function()
      local Snacks = require("snacks")
      Snacks.picker.commands()
    end, {
      desc = "Show Snacks commands",
    })
  end,
}
