-- >>> GENERAL SETTINGS
vim.loader.enable()
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_gzip = 1
vim.g.loaded_gzip_plugin = 1
vim.g.loaded_spellfile_plugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_node_provider = 1
vim.g.loaded_python3_provider = 1
vim.g.loaded_ruby_provider = 1
vim.g.loaded_perl_provider = 1
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.guicursor = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.scrolloff = 6
vim.opt.laststatus = 3
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.confirm = false
vim.opt.equalalways = false
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.undofile = true
local undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
vim.opt.undodir = undodir
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0

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

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.showmode = false

vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.path:append("**")
vim.opt.wildmenu = true
vim.opt.wildoptions:append("fuzzy")

vim.opt.lazyredraw = true

vim.opt.mouse = "a"
vim.opt.clipboard:append({ "unnamed", "unnamedplus" })
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- >>> AUTO COMMANDS
local augroup = vim.api.nvim_create_augroup("UserConfig", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Return to last edit position when opening files
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

-- Create directories when saving files
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
vim.keymap.set("n", "Q", "<nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>w", ":w<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<esc>", ":noh<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "*", "*zz", { noremap = true, silent = true })
vim.keymap.set("n", "#", "#zz", { noremap = true, silent = true })
vim.keymap.set("n", "g*", "g*zz", { noremap = true, silent = true })
vim.keymap.set("n", "g#", "g#zz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<c-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("v", "P", [["_dP]], { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { noremap = true, silent = true })
vim.keymap.set({ "n", "x", "v" }, "x", [["_x]], { noremap = true, silent = true })
vim.keymap.set("n", "Y", "yg$", { noremap = true, silent = true })
vim.keymap.set("n", "J", "mzJ`z", { noremap = true, silent = true })

vim.keymap.set("n", "<m-j>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<m-k>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("v", "<m-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<m-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })
vim.keymap.set("n", "]c", ":cnext<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "[c", ":cprev<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<F1>", ":cnext<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<F3>", ":cprev<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>fo", ":Explore<CR>", { desc = "Open file explorer" })

vim.keymap.set("n", "gh", vim.diagnostic.open_float)
vim.keymap.set("n", "<F10>", function()
  vim.diagnostic.jump({ count = 1 })
end)
vim.keymap.set("n", "<F2>", function()
  vim.diagnostic.jump({ count = -1 })
end)
vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(e)
    vim.bo[e.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.keymap.set("n", "gq", vim.diagnostic.setqflist)
    vim.keymap.set("n", "gQ", vim.diagnostic.setloclist)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
    vim.keymap.set("n", "gwd", ":vsplit | lua vim.lsp.buf.definition()<cr>")
    vim.keymap.set("n", "gwD", ":vsplit | lua vim.lsp.buf.declaration()<cr>")
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
  end,
})

-- >>> UI / VISUAL
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_enable_bold = 1
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_ui_contrast = "high"
vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
vim.g.gruvbox_material_dim_inactive_windows = 1
vim.g.gruvbox_material_float_style = "dim"
vim.g.gruvbox_material_transparent_background = 2
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox-material")

require("nvim-treesitter.configs").setup({
  highlight = { enable = true, use_languagetree = true },
  indent = { enable = true },
})
require("treesitter-context").setup({ multiline_threshold = 2 })
vim.cmd([[hi TreesitterContextBottom gui=underline]])

vim.g.borderstyle = "single"
vim.g.diag_symbol_hint = ""
vim.g.diag_symbol_error = "✗"
vim.g.diag_symbol_info = "ℹ"
vim.g.diag_symbol_warn = "⚠"

vim.diagnostic.config({
  float = { border = vim.g.borderstyle },
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = vim.g.diag_symbol_error,
      [vim.diagnostic.severity.WARN] = vim.g.diag_symbol_warn,
      [vim.diagnostic.severity.INFO] = vim.g.diag_symbol_info,
      [vim.diagnostic.severity.HINT] = vim.g.diag_symbol_hint,
    },
  },
})

vim.api.nvim_create_user_command("LspInfo", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
  else
    for _, client in ipairs(clients) do
      print("LSP: " .. client.name .. " (ID: " .. client.id .. ")")
    end
  end
end, { desc = "Show LSP client info" })

-- >>> NAVIGATION
local telescope, telescope_builtin = require("telescope"), require("telescope.builtin")
telescope.setup({
  defaults = {
    layout_strategy = "vertical",
    layout_config = {
      vertical = {
        preview_cutoff = 1,
        width = 0.95,
        height = 0.95,
      },
    },
  },
})
telescope.load_extension("zf-native")
vim.keymap.set("n", "<leader>ff", function()
  local in_git = vim.system({ "git", "rev-parse", "--is-inside-worktree" }):wait()
  if in_git.code == 0 then
    telescope_builtin.git_files()
  else
    telescope_builtin.find_files()
  end
end, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fs", telescope_builtin.live_grep, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fh", telescope_builtin.help_tags, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fb", telescope_builtin.buffers, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fp", ":Ex<cr>", { noremap = true, silent = true })

require("tmux").setup()

-- >>> TOOLS
require("conform").setup({
  formatters = {
    black = {
      command = function()
        local path = vim.fs.root(0, ".venv/bin/black")
        if path ~= nil then
          return path .. "/black"
        else
          return "black"
        end
      end,
    },
  },
  formatters_by_ft = {
    lua = { "stylua" },
    roc = { "roc" },
    ocaml = { "ocaml" },
    go = { "gofmt" },
    rust = { "rustfmt", lsp_format = "fallback" },
    zig = { "zigfmt" },
    python = { "black" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    cmake = { "cmake_format" },

    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    markdown = { "prettier" },
    ["markdown.mdx"] = { "prettier" },

    nix = { "nixpkgs_fmt" },
    bash = { "shellharden" },
    ["_"] = { "trim_whitespace" },
  },
  format_on_save = {
    timeout_ms = 1000,
    lsp_format = "fallback",
  },
})

require("lint").linters_by_ft = {
  lua = { "luacheck" },
  -- roc = { "roc" },
  go = { "golangcilint" },
  c = { "cppcheck" },
  cpp = { "cppcheck" },

  javascript = { "eslint" },
  javascriptreact = { "eslint" },
  typescript = { "eslint" },
  typescriptreact = { "eslint" },
  css = { "eslint" },
  scss = { "eslint" },
  less = { "eslint" },
  html = { "eslint" },
  json = { "eslint" },
  jsonc = { "eslint" },

  nix = { "statix" },
  bash = { "shellharden" },
  dockerfile = { "hadolint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

-- >>> LSP
local lspconfig, blink = require("lspconfig"), require("blink.cmp")

blink.setup({
  keymap = {
    preset = "default",
    ["<c-n>"] = { "select_next" },
    ["<c-e>"] = { "select_prev" },
    ["<c-y>"] = { "accept" },
    ["<c-k>"] = { "scroll_documentation_up" },
    ["<c-j>"] = { "scroll_documentation_down" },
    ["<c-u>"] = { "snippet_forward", "fallback" },
    ["<c-l>"] = { "snippet_backward", "fallback" },
  },
  completion = {
    accept = { auto_brackets = { enabled = false } },
    list = { max_items = 200, selection = { auto_insert = false } },
    menu = { border = vim.g.border_style },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
      window = {
        min_width = 10,
        max_width = 60,
        max_height = 20,
        border = vim.g.border_style,
      },
    },
  },
  signature = { enabled = true },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
})

local lsp_capabilities = blink.get_lsp_capabilities()
lsp_capabilities.textDocument.completion.completionItem = {
  documentationFormat = { "markdown", "plaintext" },
  snippetSupport = true,
  preselectSupport = true,
  insertReplaceSupport = true,
  labelDetailsSupport = true,
  deprecatedSupport = true,
  commitCharactersSupport = true,
  tagSupport = { valueSet = { 1 } },
  resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  },
}

lspconfig.astro.setup({ capabilities = lsp_capabilities })
lspconfig.bashls.setup({ capabilities = lsp_capabilities })
lspconfig.clangd.setup({ capabilities = lsp_capabilities })
lspconfig.dockerls.setup({ capabilities = lsp_capabilities })
lspconfig.lua_ls.setup({ capabilities = lsp_capabilities })
lspconfig.nixd.setup({ capabilities = lsp_capabilities })
lspconfig.ocamllsp.setup({ capabilities = lsp_capabilities })
lspconfig.rust_analyzer.setup({ capabilities = lsp_capabilities })
-- lspconfig.ruff.setup({ capabilities = lsp_capabilities })
lspconfig.ts_ls.setup({ capabilities = lsp_capabilities })
lspconfig.zls.setup({ capabilities = lsp_capabilities })

lspconfig.pyright.setup({
  capabilities = lsp_capabilities,
  on_new_config = function(config, root_dir)
    local env = vim.trim(vim.fn.system('cd "' .. (root_dir or ".") .. '"; poetry env info --executable 2>/dev/null'))
    if string.len(env) > 0 then
      config.settings.python.pythonPath = env
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.rs" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- >>> DAP
local dap, dv = require("dap"), require("dap-view")
dv.setup()

dap.listeners.before.attach["dap-view-config"] = function()
  dv.open()
end
dap.listeners.before.launch["dap-view-config"] = function()
  dv.open()
end
dap.listeners.before.event_terminated["dap-view-config"] = function()
  dv.close()
end
dap.listeners.before.event_exited["dap-view-config"] = function()
  dv.close()
end

require("dap-python").setup("python")
require("dap-go").setup()

vim.keymap.set("n", "<leader>dt", function()
  dv.toggle()
end)
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end)
vim.keymap.set("n", "<leader>dl", function()
  dap.continue()
end)
vim.keymap.set("n", "<leader>dj", function()
  dap.step_into()
end)
vim.keymap.set("n", "<leader>dk", function()
  dap.step_over()
end)
vim.keymap.set("n", "<leader>dt", function()
  if vim.bo.filetype == "python" then
    require("dap-python").test_method()
  elseif vim.bo.filetype == "go" then
    require("dap-go").debug_test()
  end
end)
