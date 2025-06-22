vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.guicursor = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
vim.opt.autoread = true

-- vim.g.gruvbox_material_enable_italic = 1
-- vim.g.gruvbox_material_enable_bold = 1
-- vim.g.gruvbox_material_better_performance = 1
-- vim.g.gruvbox_material_ui_contrast = "high"
-- vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
-- vim.g.gruvbox_material_dim_inactive_windows = 1
-- vim.g.gruvbox_material_float_style = "dim"
-- vim.g.gruvbox_material_transparent_background = 2
-- vim.o.background = "dark"
--
-- vim.cmd.colorscheme("gruvbox-material")

