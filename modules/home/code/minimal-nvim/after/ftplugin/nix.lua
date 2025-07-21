vim.api.nvim_create_user_command("TForm", function(opts)
  vim.cmd(":silent ! nixpkgs-fmt " .. opts.fargs[1])
end, { nargs = 1, desc = "Format file" })
