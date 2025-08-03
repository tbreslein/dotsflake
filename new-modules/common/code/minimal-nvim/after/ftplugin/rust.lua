vim.api.nvim_create_user_command("TForm", function(_opts)
  vim.cmd(":silent ! cargo fmt")
end, { nargs = 1, desc = "Format file" })
