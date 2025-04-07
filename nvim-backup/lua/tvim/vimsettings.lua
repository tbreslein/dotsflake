Now(function()
  vim.opt.guicursor = ""
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.colorcolumn = "80"
  vim.opt.signcolumn = "yes"
  vim.opt.cursorline = true
  vim.opt.cursorlineopt = "number"
  vim.opt.swapfile = false
  vim.opt.backup = false
  vim.opt.undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
  vim.opt.undofile = true
  vim.opt.autoread = true
  vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
  vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
  vim.opt.fileencoding = "utf-8"
  vim.g.winblend = 0
  vim.opt.laststatus = 3
  vim.opt.cmdheight = 1

  vim.g.borderstyle = "single"
  vim.g.diag_symbol_hint = "󱐮"
  vim.g.diag_symbol_error = "✘"
  vim.g.diag_symbol_info = "◉"
  vim.g.diag_symbol_warn = ""

  local shada = vim.o.shada
  vim.o.shada = ""
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      vim.o.shada = shada
      pcall(vim.cmd.rshada, { bang = true })
    end,
  })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
    callback = function()
      vim.highlight.on_yank()
    end,
  })

  vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "git", "help", "lspinfo", "man", "query", "vim" },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      Map("n", "q", "<cmd>close<cr>", { buffer = event.buf })
    end,
  })

  Map("n", "Q", "<nop>")
  Map("n", "<esc>", ":noh<cr>")
  Map("v", "P", [["_dP]])
  Map({ "n", "x", "v" }, "x", [["_x]])
  Map("n", "Y", "yg$")
  Map("n", "J", "mzJ`z")
  Map("n", "n", "nzz")
  Map("n", "N", "Nzz")
  Map("n", "*", "*zz")
  Map("n", "#", "#zz")
  Map("n", "g*", "g*zz")
  Map("n", "g#", "g#zz")
  Map("n", "<c-d>", "<c-d>zz")
  Map("n", "<c-u>", "<c-u>zz")
  Map("v", "<", "<gv")
  Map("v", ">", ">gv")
  Map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
  Map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
  Map("n", "]c", ":cnext<cr>")
  Map("n", "[c", ":cprev<cr>")
end)

Later(function()
  vim.opt.confirm = false
  vim.opt.equalalways = false
  vim.opt.splitbelow = true
  vim.opt.splitright = true
  vim.opt.timeout = false
  vim.opt.scrolloff = 5
  vim.opt.sidescrolloff = 3
  vim.opt.shiftwidth = 2
  vim.opt.smartindent = true
  vim.opt.tabstop = 2
  vim.opt.expandtab = true
  vim.opt.breakindent = true
  vim.opt.linebreak = true
  vim.opt.fillchars:append({ eob = " " })
  vim.opt.shortmess:append("aIF")
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.mouse = "a"
  vim.opt.wildmenu = true
  vim.opt.wildoptions:append("fuzzy")
  vim.opt.pumheight = 10
  vim.opt.updatetime = 400
end)
