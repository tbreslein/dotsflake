vim.api.nvim_create_user_command("TForm", function()
  print("TForm not defined")
end, { nargs = 1, desc = "Format file" })

vim.keymap.set("n", "<leader>;f", ":TForm %<cr>", { noremap = true, silent = true })
