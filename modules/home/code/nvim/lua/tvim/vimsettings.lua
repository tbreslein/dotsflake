local function init()
  -- VIM SETTINGS
  vim.loader.enable()
  vim.g.mapleader = " "
  vim.g.maplocalleader = ","

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
      vim.keymap.set("n", "q", "<cmd>close<cr>", { noremap = true, silent = true, buffer = event.buf })
    end,
  })

  vim.keymap.set("n", "Q", "<nop>", { noremap = true, silent = true })
  vim.keymap.set("n", "<esc>", ":noh<cr>", { noremap = true, silent = true })
  vim.keymap.set("v", "P", [["_dP]], { noremap = true, silent = true })
  vim.keymap.set({ "n", "x", "v" }, "x", [["_x]], { noremap = true, silent = true })
  vim.keymap.set("n", "Y", "yg$", { noremap = true, silent = true })
  vim.keymap.set("n", "J", "mzJ`z", { noremap = true, silent = true })
  vim.keymap.set("n", "n", "nzz", { noremap = true, silent = true })
  vim.keymap.set("n", "N", "Nzz", { noremap = true, silent = true })
  vim.keymap.set("n", "*", "*zz", { noremap = true, silent = true })
  vim.keymap.set("n", "#", "#zz", { noremap = true, silent = true })
  vim.keymap.set("n", "g*", "g*zz", { noremap = true, silent = true })
  vim.keymap.set("n", "g#", "g#zz", { noremap = true, silent = true })
  vim.keymap.set("n", "<c-d>", "<c-d>zz", { noremap = true, silent = true })
  vim.keymap.set("n", "<c-u>", "<c-u>zz", { noremap = true, silent = true })
  vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
  vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
  vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, silent = true, expr = true })
  vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, silent = true, expr = true })
  vim.keymap.set("n", "]c", ":cnext<cr>", { noremap = true, silent = true })
  vim.keymap.set("n", "[c", ":cprev<cr>", { noremap = true, silent = true })
  vim.keymap.set("n", "<F4>", ":cnext<cr>", { noremap = true, silent = true })
  vim.keymap.set("n", "<F3>", ":cprev<cr>", { noremap = true, silent = true })

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

  vim.g.loaded_zip = 1
  vim.g.loaded_gzip = 1
  vim.g.loaded_man = 1
  vim.g.loaded_matchit = 1
  vim.g.loaded_matchparen = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_remote_plugins = 1
  vim.g.loaded_spellfile_plugin = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_tutor_mode_plugin = 1
  vim.g.loaded_node_provider = 1
  vim.g.loaded_python3_provider = 1
  vim.g.loaded_ruby_provider = 1
  vim.g.loaded_perl_provider = 1
  vim.g.loaded_gzip_plugin = 1
end

return { init = init }
