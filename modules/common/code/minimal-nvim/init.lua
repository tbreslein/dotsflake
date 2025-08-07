-- >>> LOCALS
local o = vim.o
local opt = vim.opt
local g = vim.g
local bo = vim.bo
local wo = vim.wo
local cmd = vim.cmd
local api = vim.api
local lsp = vim.lsp
local diag = vim.diagnostic
local fn = vim.fn
local create_augroup = api.nvim_create_augroup
local create_autocmd = api.nvim_create_autocmd
local create_cmd = api.nvim_create_user_command

local function keymap(lhs, rhs, opts, mode)
  opts = type(opts) == "string" and { desc = opts }
    or vim.tbl_extend("error", opts --[[@as table]], { noremap = true, silent = true })
  mode = mode or "n"
  vim.keymap.set(mode, lhs, rhs, opts)
end

local function find_root(additional_markers)
  local markers = { ".git/" }
  vim.list_extend(markers, additional_markers)
  return vim.fs.dirname(vim.fs.find(markers, { path = fn.expand("%:p :h"), upward = true })[1])
end

-- >>> SETTINGS
g.mapleader = " "
g.maplocalleader = ","
opt.mouse = "a"
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.wildoptions = { "fuzzy", "pum", "tagfile" }
opt.confirm = false
opt.splitbelow = true
opt.splitright = false
opt.swapfile = false
local undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
if fn.isdirectory(undodir) == 0 then
  fn.mkdir(undodir, "p")
end
opt.undodir = undodir
diag.config({ virtual_text = { current_line = true } })

-- >>> AUTOCMDS
local augroup = create_augroup("UserConfig", {})
create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    local lcount = api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = fn.expand("<afile>:p:h")
    if fn.isdirectory(dir) == 0 then
      fn.mkdir(dir, "p")
    end
  end,
})

create_autocmd({ "BufEnter", "BufNewFile", "BufRead" }, {
  pattern = "*.mdx",
  callback = function()
    bo.filetype = "markdown"
  end,
})

create_autocmd("FileType", {
  pattern = { "man", "help" },
  callback = function()
    keymap("q", ":q<cr>", "quit")
  end,
})

create_autocmd("FileType", {
  pattern = { "bash", "sh" },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! shellharden --replace " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! clang-format -i " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "css",
    "scss",
    "json",
    "jsonc",
    "markdown",
  },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! prettier -w " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! stylua " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "nix" },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! nixpkgs-fmt " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    create_cmd("TForm", function(opts)
      local root_dir = find_root({ "pyproject.toml" })
      cmd(":silent ! poetry --project " .. root_dir .. " run black " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "rust" },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! cargo fmt " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "zig" },
  callback = function()
    create_cmd("TForm", function(opts)
      cmd(":silent ! zig fmt " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "gitcommit" },
  callback = function()
    bo.textwidth = 72
    wo.colorcolumn = "+0"
    wo.spell = true
  end,
})

create_autocmd("FileType", {
  pattern = { "go", "makefile" },
  callback = function()
    bo.expandtab = false
  end,
})

create_augroup("Git", {})
create_autocmd("BufEnter", {
  group = "Git",
  pattern = "COMMIT_EDITMSG",
  callback = function()
    wo.spell = true
    api.nvim_win_set_cursor(0, { 1, 0 })
    if fn.getline(1) == "" then
      cmd("startinsert!")
    end
  end,
})

-- >>> KEYMAPS
keymap("<leader>w", ":w<cr>", "write")
keymap("<esc>", ":noh<cr>", "remove hlsearch")
keymap("n", "nzzzv", "center after n")
keymap("N", "Nzzzv", "center after N")
keymap("*", "*zz", "center after *")
keymap("#", "#zz", "center after #")
keymap("g*", "g*zz", "center after g*")
keymap("g#", "g#zz", "center after g#")
keymap("<c-d>", "<c-d>zz", "center after c-d")
keymap("<c-u>", "<c-u>zz", "center after c-u")
keymap("P", [["_dP]], "paste without overwriting register", "v")
keymap("<leader>d", [["_d]], "d without overwriting register", { "n", "v" })
keymap("<leader>x", [["_x]], "x without overwriting register", { "n", "x", "v" })
keymap("Y", "yg$", "yank till end of line")
keymap("<leader>y", [["+y]], "yank into clipboard", "v")
keymap("<leader>Y", [["+yg$]], "yank till end of line into clipboard")
keymap("<leader>p", [["+p]], "paste from clipboard", { "n", "v" })
keymap("J", "mzJ`z", "better join")
keymap("<m-j>", ":m .+1<cr>==", "")
keymap("<m-k>", ":m .-2<cr>==", "")
keymap("<m-h>", ":m '>+1<cr>gv=gv", "", "v")
keymap("<m-l>", ":m '<-2<cr>gv=gv", "", "v")
keymap("<", "<gv", "de-indent", "v")
keymap(">", ">gv", "indent", "v")
keymap("]c", ":cnext<cr>", "cnext")
keymap("[c", ":cprev<cr>", "cprev")
keymap("<F8>", ":cnext<cr>", "cnext")
keymap("<F7>", ":cprev<cr>", "cprev")
keymap("<leader>fo", ":Explore<cr>", "netrw")
keymap("jk", "<C-\\><C-n>", "normal mode", "t")
keymap("<leader>;f", ":TForm %<cr>", "run formatter")
keymap("<leader>;t", ":TTest<cr>", "run tests")
keymap("<leader>;c", ":TCheck<cr>", "run lints")
keymap("<leader>;m", ":make<cr>", "run make")

-- >>> UI
g.gruvbox_material_enable_italic = 1
g.gruvbox_material_enable_bold = 1
g.gruvbox_material_ui_contrast = "high"
g.gruvbox_material_transparent_background = 2
o.background = "dark"
cmd("silent! colorscheme gruvbox-material")

require("nvim-treesitter.configs").setup({
  highlight = { enable = true, use_languagetree = true },
  indent = { enable = true },
})
require("treesitter-context").setup({ multiline_threshold = 2 })
cmd([[hi TreesitterContextBottom gui=underline]])

opt.winborder = "single"

opt.guicursor = ""
opt.number = true
opt.relativenumber = true
opt.colorcolumn = "80"
opt.signcolumn = "no"
opt.cursorline = true
opt.cursorlineopt = "screenline"
opt.scrolloff = 5

o.foldenable = true
o.foldlevel = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
opt.foldcolumn = "0"
opt.fillchars:append({ fold = " " })

-- >>> NAVIGATION
vim.opt.grepprg = "rg --vimgrep --ignore-file=.gitignore --iglob='!.git/' --iglob='!**/*.ipynb'"

local function fuzzy_search(cmd, exit_fn)
  local width = o.columns - 4
  local height = 11

  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "modifiable", true)
  keymap("<esc>", ":bd!<cr>", { desc = "exit", buffer = buf }, "i")

  api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    noautocmd = true,
    width = width,
    height = height,
    col = 1,
    row = math.min((o.lines - height) / 2 - 1),
  })
  local file = fn.tempname()
  api.nvim_command("startinsert!")

  fn.jobstart(cmd .. " > " .. file, {
    term = true,
    on_exit = function()
      local f = io.open(file, "r")
      if f == nil then
        return
      end
      local stdout = f:read("*all")
      exit_fn(stdout)
      f:close()
      os.remove(file)
    end,
  })
end

local function file_search(fd_flags)
  fuzzy_search("fd -tf " .. fd_flags .. " | fzy", function(stdout)
    local selected, _ = stdout:gsub("\n", "")
    if #selected > 0 then
      cmd("bd!")
      cmd("e " .. selected)
    end
  end)
end

keymap("<leader>ff", function()
  file_search("")
end, "file search")
keymap("<leader>fg", function()
  file_search("-u")
end, "file search hidden")

-- vim.keymap.set("n", "<leader>fs", function()
--   fuzzy.fuzzy_search([[sk --reverse -m --ansi -i -c 'rg --color=always --line-number "{}"']], function(stdout)
--     local lines = vim.split(stdout, "\n", { plain = true, trimempty = true })
--     vim.cmd("bd!")
--     if #lines > 1 then
--       fn.setqflist({}, "r", { lines = lines })
--       vim.cmd("copen")
--     elseif #lines == 1 then
--       vim.cmd("e " .. lines[1])
--     end
--   end)
-- end)

-- >>> COMPLETION
o.completeopt = "fuzzy,menuone,noselect,noinsert,popup"
o.pumheight = 20
o.pumwidth = 42

create_autocmd("LspAttach", {
  callback = function(ev)
    bo[e.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    keymap("gq", diag.setqflist, "setqflist")
    keymap("gQ", diag.setloclist, "setloclist")
    keymap("gd", lsp.buf.definition, "goto definition")
    keymap("gD", lsp.buf.declaration, "goto declaration")
    keymap("gwd", ":vsplit | lua vim.lsp.buf.definition()<cr>", "goto definition in vsplit")
    keymap("gwD", ":vsplit | lua vim.lsp.buf.declaration()<cr>", "goto declaration in vsplit")
    keymap("gt", lsp.buf.type_definition, "goto typedef")
    keymap("gi", lsp.buf.implementation, "goto impl")

    -- keymap("<c-j>", vim.lsp.completion.get, "start completion")

    lsp.completion.enable(true, ev.data.client_id, ev.buf, {
      convert = function(item)
        local abbr = item.label
        abbr = abbr:gsub("%b()", ""):gsub("%b{}", "")
        abbr = abbr:match("[%w_.]+.*") or abbr
        abbr = #abbr > 15 and abbr:sub(1, 14) .. "…" or abbr

        local menu = item.detail or ""
        menu = #menu > 15 and menu:sub(1, 14) .. "…" or menu

        return { abbr = abbr, menu = menu }
      end,
    })
  end,
})

lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = api.nvim_get_runtime_file("", true) },
      telemetry = { enable = true },
    },
  },
})

local function set_python_path(path)
  local clients = vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = "pyright",
  })
  for _, client in ipairs(clients) do
    if client.settings then
      client.settings.python = vim.tbl_deep_extend("force", client.settings.python, { pythonPath = path })
    else
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
    end
    client.notify("workspace/didChangeConfiguration", { settings = nil })
  end
end

lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "openFilesOnly",
      },
    },
  },
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
      client:exec_cmd({
        command = "pyright.organizeimports",
        arguments = { vim.uri_from_bufnr(bufnr) },
      })
    end, {
      desc = "Organize Imports",
    })
    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
      desc = "Reconfigure pyright with the provided python path",
      nargs = 1,
      complete = "file",
    })
  end,
  on_new_config = function(config, root_dir)
    local env =
      vim.trim(vim.fn.system('cd "' .. (root_dir or ".") .. '" │ ; poetry env info --executable 2>/dev/null'))
    if string.len(env) > 0 then
      config.settings.python.pythonPath = env
    end
  end,
})

lsp.enable({ "lua_ls", "pyright", "rust_analyzer" })

-- >>> DAP
-- local dap, dv = require("dap"), require("dap-view")
-- dv.setup()
--
-- dap.listeners.before.attach["dap-view-config"] = function()
--   dv.open()
-- end
-- dap.listeners.before.launch["dap-view-config"] = function()
--   dv.open()
-- end
-- dap.listeners.before.event_terminated["dap-view-config"] = function()
--   dv.close()
-- end
-- dap.listeners.before.event_exited["dap-view-config"] = function()
--   dv.close()
-- end
--
-- require("dap-python").setup("python")
-- require("dap-go").setup()
--
-- keymap("<leader>dt", function()
--   dv.toggle()
-- end, "dap view toggle")
-- keymap("<leader>db", function()
--   dap.toggle_breakpoint()
-- end, "dap toggle breakpoint")
-- keymap("<leader>dl", function()
--   dap.continue()
-- end, "dap continue")
-- keymap("<leader>dj", function()
--   dap.step_into()
-- end, "dap step into")
-- keymap("<leader>dk", function()
--   dap.step_over()
-- end, "dap step over")
-- keymap("<leader>dt", function()
--   if bo.filetype == "python" then
--     require("dap-python").test_method()
--   elseif bo.filetype == "go" then
--     require("dap-go").debug_test()
--   end
-- end, "dap test")
