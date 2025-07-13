local M = {}
local api = vim.api
local o = vim.o
local fn = vim.fn

function M.fuzzy_search(cmd, exit_fn)
  local width = o.columns - 4
  if o.columns >= 85 then
    width = 80
  end
  local height = o.lines - 10

  buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "modifiable", true)

  api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    noautocmd = true,
    width = width,
    height = height,
    col = math.min((o.columns - width) / 2),
    row = math.min((o.lines - height) / 2 - 1),
  })
  local file = vim.fn.tempname()
  api.nvim_command("startinsert!")

  vim.fn.termopen(cmd .. " > " .. file, {
    on_exit = function()
      local f = io.open(file, "r")
      stdout = f:read("*all")
      exit_fn(stdout)
      f:close()
      os.remove(file)
    end,
  })
end
return M
