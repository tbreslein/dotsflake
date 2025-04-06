vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = ","

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

local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end
require("mini.deps").setup({ path = { package = path_package } })

function Map(mode, keys, action, opts, desc)
  vim.keymap.set(mode, keys, action, vim.tbl_extend("keep", opts or {}, { noremap = true, silent = true, desc = desc }))
end

Add, Now, Later = MiniDeps.add, MiniDeps.now, MiniDeps.later

require("tvim.vimsettings")
require("tvim.ui")
require("tvim.statusline")
require("tvim.navigation")
require("tvim.lsp")
require("tvim.tools")
require("tvim.dap")
