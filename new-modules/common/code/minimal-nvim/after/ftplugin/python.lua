local root_dir = require("tvim.utils").find_root({ "pyproject.toml" })

vim.api.nvim_create_user_command("TForm", function(opts)
  vim.cmd(":silent ! poetry --project " .. root_dir .. " run black " .. opts.fargs[1])
end, { nargs = 1, desc = "Format file" })
