vim.api.nvim_create_user_command("TForm", function(_opts)
  vim.cmd(":silent ! clang-format -i %")
end, { nargs = 1, desc = "Format file" })
