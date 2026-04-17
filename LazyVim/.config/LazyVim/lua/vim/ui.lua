-- Compatibility shim for plugins requiring the module form of vim.ui.
-- We forward to the builtin module so we keep all of its helpers intact.
local function load_builtin_ui()
  local current = debug.getinfo(1, "S").source
  if current:sub(1, 1) == "@" then
    current = current:sub(2)
  end

  local runtime_files = vim.api.nvim_get_runtime_file("lua/vim/ui.lua", true)
  for _, path in ipairs(runtime_files) do
    if path ~= current then
      local chunk, err = loadfile(path)
      if chunk then
        local ok, mod = pcall(chunk)
        if ok then
          return mod
        else
          vim.schedule(function()
            vim.notify(
              ("Failed loading builtin vim.ui from %s: %s"):format(path, mod),
              vim.log.levels.ERROR
            )
          end)
        end
      else
        vim.schedule(function()
          vim.notify(
            ("Could not read builtin vim.ui from %s: %s"):format(path, err),
            vim.log.levels.ERROR
          )
        end)
      end
    end
  end
end

local M = load_builtin_ui() or rawget(vim, "ui") or {}

rawset(vim, "ui", M)

return M
