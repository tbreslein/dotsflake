vim.api.nvim_create_user_command("TForm", function(opts)
  vim.cmd(":silent ! stylua " .. opts.fargs[1])
end, { nargs = 1, desc = "Format file" })
