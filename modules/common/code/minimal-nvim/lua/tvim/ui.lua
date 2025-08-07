vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_enable_bold = 1
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_ui_contrast = "high"
vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
vim.g.gruvbox_material_dim_inactive_windows = 1
vim.g.gruvbox_material_float_style = "dim"
vim.g.gruvbox_material_transparent_background = 2
vim.o.background = "dark"
vim.cmd("silent! colorscheme gruvbox-material")

require("nvim-treesitter.configs").setup({
  highlight = { enable = true, use_languagetree = true },
  indent = { enable = true },
})
require("treesitter-context").setup({ multiline_threshold = 2 })
vim.cmd([[hi TreesitterContextBottom gui=underline]])

vim.g.borderstyle = "single"
vim.opt.winborder = vim.g.borderstyle
vim.g.diag_symbol_hint = ""
vim.g.diag_symbol_error = "✗"
vim.g.diag_symbol_info = "ℹ"
vim.g.diag_symbol_warn = "⚠"
