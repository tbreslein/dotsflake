-- references:
--   - capture term output:
--     - run the term command, then use nvim_buf_lines to yank all but the last two lines
--     - https://www.reddit.com/r/neovim/comments/tazw3r/how_to_do_read_interactive_command_output/
--     - use this to run `:term fd | fzf` to open files
--     - `:term rg INPUT | fzf` to grep, if vimgrep does not suffice -> dump into qflist
--   - when using :vimgrep/:grep, set grepprg to something reasonable like:
--       rg --ignore-file=.gitignore --iglob=.git/ --iglob=**/*.ipynb
--   - consider using:
--     - fzy + livegrep:
--       - https://github.com/jhawthorn/fzy?tab=readme-ov-file
--       - https://github.com/livegrep/livegrep
--     - skim (which can also livegrep):
--       - https://github.com/skim-rs/skim?tab=readme-ov-file#usage
--     - just use fzy and do some magic with rerunning rg on keypress and piping in into fzy
--   - define usercommands in ftplugins for formatting, linting, compiling, and running tests
--     - :TForm to run the formatter, maybe invoke this in a BufWritePre auto command?
--     - :TLint to run linters and dump output into qflist
--     - :Make to run compiler
--     - :TTest to run tests in a split terminal?
--   - also use the ftplugins for configs like indent and expandtab (for makefiles)
--   - use builtin snippets and autocomplete for text and files
--   - snippets:
--     - https://www.reddit.com/r/neovim/comments/1cxfhom/builtin_snippets_so_good_i_removed_luasnip/
--     - https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc
--   - debugging:
--     - zed: https://zed.dev/docs/development/debuggers
--     - i MIGHT use a plugin for debugging, if i cannot setup zed for that
--     - nvim dap: https://youtu.be/cxpWjlNXeQA?si=vbocJxlP2odku6Yp
--
--   - videos on pluginless neovim:
--     - https://youtu.be/XA2WjJbmmoM?si=nrSvG-iiLWvyPZn6
--     - https://youtu.be/I5kT2c2XX38?si=9AJUw-moMT5hUvFk
--     - https://youtu.be/HiAs7oNDyh0?si=ma-xzh6JFv52z2eI
--     - https://youtu.be/skW3clVG5Fo?si=rR_Uijd9CWAGRNWG
--     - https://youtu.be/mQ9gmHHe-nI?si=IcPMAwCk_9DPJpDi
--   - netrw:
--     - https://youtu.be/g2LTTq9hkbU?si=fbZ2aGq63l6MpV-2
--     - https://youtu.be/nbKkKbENgd8?si=nTf4lPt8YilgpBt9
--     - https://youtu.be/nDGhjk4Eqbc?si=3_SowkNGXDNIY8cp
--     - https://youtu.be/3lqzc77carU?si=K9cYv7lbbLIwO7O-
--     - https://youtu.be/VNDoMhKVdQM?si=ik-IpCYDMdXgSOuD
--     - https://youtu.be/9UxMvz6u1K4?si=jIZzdHTt48vOad5I
--     - https://youtu.be/GyPXYF6jgwk?si=8qhkJshwZF2h5p81
--
-- TODO:
--   - split config into files
--   - get the fuzzy finder running

-- >>> SETTINGS
vim.loader.enable()
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_gzip = 1
vim.g.gzip_exec = 1
vim.g.loaded_spellfire_plugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.mouse = "a"

vim.opt.guicursor = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.scrolloff = 5
vim.opt.laststatus = 3

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.showmatch = true
vim.opt.matchtime = 2

vim.opt.completeopt = { "fuzzy", "menuone", "noinsert", "noselect" }
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildoptions = { "fuzzy", "pum", "tagfile" }
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

vim.opt.lazyredraw = true
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.confirm = false
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
local undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir

-- >>> AUTOCMDS
local augroup = vim.api.nvim_create_augroup("UserConfig", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "makefile" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

-- >>> KEYMAPS
vim.keymap.set("n", ";;", ":w<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<esc>w", ":noh<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "*", "*zz", { noremap = true, silent = true })
vim.keymap.set("n", "#", "#zz", { noremap = true, silent = true })
vim.keymap.set("n", "g*", "g*zz", { noremap = true, silent = true })
vim.keymap.set("n", "g#", "g#zz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-d>", "<c-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-u>", "<c-u>zz", { noremap = true, silent = true })
vim.keymap.set("v", "P", [["_dP]], { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "v" }, "<leader>x", [["_x]], { noremap = true, silent = true })
vim.keymap.set("n", "Y", "yg$", { noremap = true, silent = true })
vim.keymap.set("n", "J", "mzJ`z", { noremap = true, silent = true })
vim.keymap.set("n", "<m-j>", ":m .+1<cr>==", { noremap = true, silent = true })
vim.keymap.set("n", "<m-k>", ":m .-2<cr>==", { noremap = true, silent = true })
vim.keymap.set("v", "<m-h>", ":m '>+1<cr>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<m-l>", ":m '<-2<cr>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("n", "]c", ":cnext<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "[c", ":cprev<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<F1>", ":cnext<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<F3>", ":cprev<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fo", ":Explore<cr>", { noremap = true, silent = true })

-- >>> UI
vim.cmd.colorscheme("retrobox")
