vim.opt.grepprg = "rg --vimgrep --ignore-file=.gitignore --iglob='!.git/' --iglob='!**/*.ipynb'"
require("mini.pick").setup({
  window = {
    config = { height = 11, width = vim.o.columns - 2}
  },
})

vim.ui.select = MiniPick.ui_select
vim.keymap.set("n", "<leader>ff", MiniPick.builtin.files)
vim.keymap.set("n", "<leader>fs", MiniPick.builtin.grep_live)

require("mini.files").setup({})
vim.keymap.set("n", "<leader>fo", function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end)
