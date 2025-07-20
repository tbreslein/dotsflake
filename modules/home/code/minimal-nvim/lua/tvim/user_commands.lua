vim.api.nvim_create_user_command("TForm", function()
  print("TForm not defined")
end, { nargs = 1, desc = "Format file" })
vim.keymap.set("n", "<leader>;f", ":TForm %<cr>", { noremap = true, silent = true })

vim.api.nvim_create_user_command("TTest", function()
  print("TTest not defined")
end, { nargs = 0, desc = "Test project" })
vim.keymap.set("n", "<leader>;t", ":TTest<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>;m", ":make<cr>", { noremap = true, silent = true })
