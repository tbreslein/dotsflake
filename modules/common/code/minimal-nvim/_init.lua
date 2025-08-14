-- TODO:
-- restructure this config as follows:
--   - put everything that I want to be able to configure in tables at the TOP
--     of the file (the porcelain)
--     - the tables do not include simple vim.g and vim.opt settings. those are
--       simple enough to just be spelt out
--   - put all functions and other locals in a section below that
--   - use those functions to apply the config at the bottom
--
-- basically, write a config API for my own config, so that extending it becomes
-- easier

vim.g.mapleader = " "
vim.g.maplocalleader = ","
-- >>> PREAMBLE {{{2
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

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
})

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

local function is_git_repo()
  _ = fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

-- taken from Vitaly Kurin on Youtube:
-- use these to dump the output of an external command into a scratchbuffer
--   - git blame, diff, ...
--   - grep in file
--   - linting (which means I can use this for Tcheck)
-- and if it's in qf format, you can manually edit the list and dump that into
-- the qflist
local function scratch_to_quickfix()
  local bufnr = api.nvim_get_current_buf()
  local items = {}
  for _, line in ipairs(api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line ~= "" then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if filename and lnum then
        -- used for grep filename:line:text
        table.insert(items, { filename = filename, lnum = tonumber(lnum), text = text })
      else
        lnum, text = line:match("^(%d+):(.*)$")
        if lnum and text then
          -- used for current buffer grep
          table.insert(items, { filename = fn.bufname(fn.bufnr("#")), lnum = tonumber(lnum), text = text })
        else
          -- only filenames
          table.insert(items, { filename = fn.fnamemodify(line, ":p"), lnum = 1, text = "" })
        end
      end
    end
  end
  api.nvim_buf_delete(bufnr, { force = true })
  fn.setqflist(items, "r")
  cmd("copen | cc")
end

-- the quickfix parameter is useful for linters
local function extcmd_to_scratch(extcmd, quickfix)
  local output = {}
  if type(extcmd) == "table" then
    output = fn.systemlist(extcmd)
  else
    output = { fn.system(vim.split(extcmd, "\n")) }
  end

  if #output == 0 then
    return
  end

  cmd("vnew")
  api.nvim_buf_set_lines(0, 0, -1, false, output)
  bo.buftype = "nofile"
  bo.bufhidden = "wipe"
  bo.swapfile = false

  if quickfix then
    scratch_to_quickfix()
  end
end

local function fuzzy_search(_cmd, exit_fn)
  local width = o.columns - 2
  if width > 120 then
    width = 120
  end
  local height = 12

  local buf = api.nvim_create_buf(false, true)
  api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  api.nvim_set_option_value("modifiable", true, { buf = buf })
  keymap("<esc>", ":bd!<cr>", { desc = "exit", buffer = buf }, "i")

  api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    noautocmd = true,
    width = width,
    height = height,
    col = math.min((o.columns - width) / 2),
    row = o.lines - height,
  })
  local file = fn.tempname()
  api.nvim_command("startinsert!")

  fn.jobstart(_cmd .. " > " .. file, {
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

local function file_search()
  local _cmd = ""
  if is_git_repo() then
    _cmd = "git ls-files"
  else
    _cmd = "find . -type f"
  end
  fuzzy_search(_cmd .. " | fzf --height=12 --reverse --border=none", function(stdout)
    local selected, _ = stdout:gsub("\n", "")
    if #selected > 0 then
      cmd("bd!")
      cmd("e " .. selected)
    end
  end)
end

-- >>> SETTINGS {{{1
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
opt.undofile = true
g.grepprg = "git grep -nE"

diag.config({ virtual_lines = { current_line = true } })

-- >>> AUTOCMDS
local user_group = create_augroup("UserConfig", {})
create_autocmd("TextYankPost", {
  group = user_group,
  callback = function()
    vim.highlight.on_yank()
  end,
})

create_autocmd("BufReadPost", {
  group = user_group,
  callback = function()
    local mark = api.nvim_buf_get_mark(0, '"')
    local lcount = api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

create_autocmd("BufWritePre", {
  group = user_group,
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

create_cmd("Tup", function(opts)
  local packs = {}
  if #opts.args > 0 then
    if type(opts.args) == "string" then
      packs = { opts.args }
    else
      packs = opts.args --[[@as table]]
    end
  end
  vim.pack.update(packs)
  vim.cmd("TSUpdate")
end, { nargs = "*", desc = "update packages" })

create_cmd("Tgrep", function(opts)
  if is_git_repo() then
    extcmd_to_scratch({
      "git",
      "grep",
      "-nE",
      opts.args,
    }, not opts.bang)
  else
    extcmd_to_scratch({
      "rg",
      "--vimgrep",
      "--no-column",
      "-ne",
      opts.args,
    }, not opts.bang)
  end
end, { nargs = "+", desc = "Format file", bang = true })

local git_group = create_augroup("Git", {})
create_autocmd("BufEnter", {
  group = git_group,
  pattern = "COMMIT_EDITMSG",
  callback = function()
    wo.spell = true
    api.nvim_win_set_cursor(0, { 1, 0 })
    if fn.getline(1) == "" then
      cmd("startinsert!")
    end
  end,
})

create_autocmd("BufEnter", {
  group = user_group,
  pattern = "*nvim/init.lua",
  callback = function()
    o.foldmethod = "marker"
    o.foldlevel = 2
  end,
})

local ft_autocmds = {
  {
    { "c", "cpp" },
    tform = "clang-format -i",
  },
  {
    "go",
    misc = function()
      bo.expandtab = false
    end,
  },
  {
    "python",
    tform = function()
      return "poetry --project " .. find_root({ "pyproject.toml" }) .. " run black"
    end,
  },
  {
    "rust",
    tform = "cargo fmt",
  },
  {
    "zig",
    tform = "zig fmt",
  },
  {
    { "bash", "sh" },
    tform = "shellharden",
  },
  {
    "lua",
    tform = "stylua",
  },
  {
    "nix",
    tform = "nixpkgs-fmt",
  },
  {
    {
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
    tform = "prettier -w",
  },
  {
    { "man", "help" },
    misc = function()
      -- keymap("q", ":q<cr>", "quit")
    end,
  },
  {
    "gitcommit",
    misc = function()
      bo.textwidth = 72
      wo.colorcolumn = "+0"
      wo.spell = true
    end,
  },
}

for _, v in ipairs(ft_autocmds) do
  create_autocmd("FileType", {
    pattern = v[1],
    callback = function()
      if v.tform ~= nil then
        local tform_str = ":silent ! "
        if type(v.tform) == "function" then
          tform_str = tform_str .. v.tform()
        else
          tform_str = tform_str .. v.tform
        end
        create_cmd("Tform", function(opts)
          cmd(tform_str .. " " .. opts.fargs[1])
        end, { nargs = 1, desc = "Format file" })
      end

      if v.misc ~= nil and type(v.misc) == "function" then
        v.misc()
      end
    end,
  })
end
-- keymap("<leader>;c", function() extcmd_to_scratch({ "ruff", "check", fn.expand("%") }, true) end)

-- >>> KEYMAPS
keymap("<leader>w", ":w<cr>", "write")
keymap("<leader>a", ":e #<cr>", "switch to alternate file", { "n", "x", "v" })
keymap("<leader>A", ":sf #<cr>", "split find alternate file", { "n", "x", "v" })
keymap("<leader>n", ":set relativenumber!<cr>", "toggle relative lines")
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
keymap("<m-j>", ":m .+1<cr>==", "move line down")
keymap("<m-k>", ":m .-2<cr>==", "move line up")
keymap("<m-j>", ":m '>+1<cr>gv=gv", "move block down", "v")
keymap("<m-k>", ":m '<-2<cr>gv=gv", "move block up", "v")
keymap("<", "<gv", "de-indent", "v")
keymap(">", ">gv", "indent", "v")
keymap("<c-h>", "<c-w>h", "move to split left")
keymap("<c-j>", "<c-w>j", "move to split down")
keymap("<c-k>", "<c-w>k", "move to split up")
keymap("<c-l>", "<c-w>l", "move to split right")
keymap("<m-H>", "<cmd>vertical resize -2<cr>", "decrease width")
keymap("<m-J>", "<cmd>resize +2<cr>", "increase height")
keymap("<m-K>", "<cmd>resize -2<cr>", "decrease height")
keymap("<m-L>", "<cmd>vertical resize +2<cr>", "increase width")
keymap("<c-s><c-s>", ":split<cr>", "horizontal split")
keymap("<c-s><c-v>", ":vsplit<cr>", "vertical split")
keymap("<F8>", ":cnext<cr>", "cnext")
keymap("<F7>", ":cprev<cr>", "cprev")
keymap("<F6>", ":cclose<cr>", "cprev")
keymap("<F4>", function()
  vim.diagnostic.jump({ count = 1 })
end, "cnext")
keymap("<F3>", function()
  vim.diagnostic.jump({ count = -1 })
end, "cnext")
-- default keybinds:
-- "grn" is mapped in Normal mode to vim.lsp.buf.rename()
-- "gra" is mapped in Normal and Visual mode to vim.lsp.buf.code_action()
-- "grr" is mapped in Normal mode to vim.lsp.buf.references()
-- "gri" is mapped in Normal mode to vim.lsp.buf.implementation()
-- "grt" is mapped in Normal mode to vim.lsp.buf.type_definition()
-- "gO" is mapped in Normal mode to vim.lsp.buf.document_symbol()
-- CTRL-S is mapped in Insert mode to vim.lsp.buf.signature_help()
keymap("<leader>fp", ":Explore<cr>", "netrw")
keymap("jk", "<C-\\><C-n>", "normal mode", "t")
keymap("<leader>;f", ":Tform %<cr>", "run formatter")
keymap("<leader>;t", ":Ttest<cr>", "run tests")
keymap("<leader>;c", ":Tcheck<cr>", "run lints")
keymap("<leader>;m", ":make<cr>", "run make")

keymap("<leader>mp", "mP", "mark P")
keymap("<leader>mf", "mF", "mark F")
keymap("<leader>mw", "mW", "mark W")
keymap("<leader>mq", "mQ", "mark Q")
keymap("<leader>mb", "mB", "mark B")

keymap("<m-p>", "`P", "goto mark P")
keymap("<m-f>", "`F", "goto mark F")
keymap("<m-w>", "`W", "goto mark W")
keymap("<m-q>", "`Q", "goto mark Q")
keymap("<m-b>", "`B", "goto mark B")

keymap("<leader>ff", file_search, "file search")

keymap("<leader>x", scratch_to_quickfix, "dump buffer content to quickfix")
keymap("<leader>gd", function()
  extcmd_to_scratch({ "git", "diff" })
end, "send git diff to scratch")
keymap("<leader>gb", function()
  extcmd_to_scratch({ "git", "blame", fn.expand("%") })
end, "send git blame to scratch")
keymap("<leader>gb", function()
  extcmd_to_scratch({ "git", "blame", fn.expand("%") })
end, "send git blame to scratch")

-- TODO add visual mode variants that copy the visual selection and grep that.
-- to do that, i have to yank into a register (maybe v), and copy that
-- ref: https://www.reddit.com/r/neovim/comments/1bolf8l/search_and_replace_the_visual_selection/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
keymap("<leader>sf", function()
  vim.ui.input({
    prompt = "> ",
  }, function(pat)
    if pat then
      cmd("Tgrep " .. pat)
    end
  end)
end, "search pattern with rg, and send to qf")

keymap("<leader>ss", function()
  vim.ui.input({
    prompt = "> ",
  }, function(pat)
    if pat then
      cmd("Tscratch " .. pat)
    end
  end)
end, "search pattern with rg, and send to scratch")

-- >>> UI
require("nvim-treesitter.configs").setup({
  highlight = { enable = true, additional_vim_regex_highlighting = { "markdown" } },
  ensure_installed = "all",
  ignore_install = { "ipkg" },
  sync_install = true,
  auto_install = true,
  indent = { enable = true },
})
require("treesitter-context").setup({ multiline_threshold = 2 })

opt.winborder = "single"

opt.guicursor = ""
opt.number = true
opt.relativenumber = true
opt.colorcolumn = "80"
opt.signcolumn = "no"
opt.cursorline = true
opt.cursorlineopt = "screenline"
opt.scrolloff = 5
opt.laststatus = 3

o.foldenable = true
o.foldlevel = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
opt.foldcolumn = "0"
-- opt.fillchars:append({ fold = " " })

g.netrw_banner = 0
-- g.netrw_browse_split = 4
-- g.netrw_altv = 1
g.netrw_liststyle = 3

-- >>> COMPLETION
o.completeopt = "fuzzy,menu,menuone,noselect,noinsert,popup,preview"
o.pumheight = 20
o.pumwidth = 45

local function pumvisible()
  return tonumber(vim.fn.pumvisible()) ~= 0
end

--For replacing certain <C-x>... keymaps.
local function feedkeys(keys)
  api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

keymap("<c-i>", function()
  return pumvisible() and "<c-e>" or "<c-i>"
end, { expr = true, desc = "cancel completion" }, "i")

-- Buffer completions.
keymap("<C-u>", "<C-x><C-n>", { desc = "Buffer completions" }, "i")

-- Use <c-n> to navigate to the next completion or:
-- - Trigger LSP completion.
-- - If there's no one, fallback to vanilla omnifunc.
keymap("<c-n>", function()
  if pumvisible() then
    feedkeys("<c-n>")
  elseif bo.omnifunc == "" then
    feedkeys("<c-x><c-n>")
  else
    feedkeys("<c-x><c-o>")
  end
end, "trigger/next completion", "i")

-- Use <c-k> to navigate to the previous completion or:
-- - Trigger LSP completion.
-- - If there's no one, fallback to vanilla omnifunc.
keymap("<c-e>", function()
  if pumvisible() then
    feedkeys("<c-p>")
  elseif bo.omnifunc == "" then
    feedkeys("<c-x><c-p>")
  else
    feedkeys("<c-x><c-o>")
  end
end, "trigger/prev completion", "i")

create_autocmd("LspAttach", {
  callback = function(ev)
    -- most of this was lifted from this gist:
    -- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc#file-builtin-compl-lua
    local bufnr = ev.buf
    local client = lsp.get_client_by_id(ev.data.client_id)

    local function bufmap(lhs, rhs, opts, mode)
      opts = type(opts) == "string" and { desc = opts }
        or vim.tbl_extend("error", opts --[[@as table]], { buffer = bufnr })
      mode = mode or "n"
      keymap(lhs, rhs, opts, mode)
    end

    bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    bufmap("gq", diag.setqflist, "setqflist")
    bufmap("gQ", diag.setloclist, "setloclist")
    bufmap("gd", lsp.buf.definition, "goto definition")
    bufmap("gD", lsp.buf.declaration, "goto declaration")
    bufmap("gwd", ":vsplit | lua vim.lsp.buf.definition()<cr>", "goto definition in vsplit")
    bufmap("gwD", ":vsplit | lua vim.lsp.buf.declaration()<cr>", "goto declaration in vsplit")
    bufmap("gt", lsp.buf.type_definition, "goto typedef")
    bufmap("gi", lsp.buf.implementation, "goto impl")

    if client and client:supports_method("textDocument/completion") then
      lsp.completion.enable(true, ev.data.client_id, bufnr, {
        convert = function(item)
          local abbr = item.label
          abbr = abbr:gsub("%b()", ""):gsub("%b{}", "")
          abbr = abbr:match("[%w_.]+.*") or abbr
          abbr = #abbr > 21 and abbr:sub(1, 20) .. "…" or abbr

          local menu = item.detail or ""
          menu = #menu > 21 and menu:sub(1, 20) .. "…" or menu

          return { abbr = abbr, menu = menu }
        end,
      })
    end

    -- Use <Tab> to navigate between snippet tabstops.
    -- Do something similar with <S-Tab>.
    bufmap("<Tab>", function()
      -- -- example of how to integrate something like copilot
      -- local copilot = require("copilot.suggestion")
      --
      -- if copilot.is_visible() then
      --   copilot.accept()
      -- elseif ...
      if vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
      else
        feedkeys("<Tab>")
      end
    end, {}, { "i", "s" })

    bufmap("<S-Tab>", function()
      if vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
      else
        feedkeys("<S-Tab>")
      end
    end, {}, { "i", "s" })

    -- Inside a snippet, use backspace to remove the placeholder.
    bufmap("<BS>", "<C-o>s", {}, "s")
  end,
})

lsp.enable({ "lua_ls", "pyright", "rust_analyzer" })

local function set_python_path(path)
  local clients = lsp.get_clients({
    bufnr = api.nvim_get_current_buf(),
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
    api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
      client:exec_cmd({
        command = "pyright.organizeimports",
        arguments = { vim.uri_from_bufnr(bufnr) },
      })
    end, {
      desc = "Organize Imports",
    })
    api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
      desc = "Reconfigure pyright with the provided python path",
      nargs = 1,
      complete = "file",
    })
  end,
  on_new_config = function(config, root_dir)
    local env = vim.trim(fn.system('cd "' .. (root_dir or ".") .. '" │ ; poetry env info --executable 2>/dev/null'))
    if string.len(env) > 0 then
      config.settings.python.pythonPath = env
    end
  end,
})

lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".git" },
  settings = { Lua = { workspace = { library = api.nvim_get_runtime_file("", true) } } },
})

lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
  -- capabilities = { experimental = { serverStatusNotification = true } },
  -- before_init = function(init_params, config)
  --   -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
  --   if config.settings and config.settings["rust-analyzer"] then
  --     init_params.initializationOptions = config.settings["rust-analyzer"]
  --   end
  -- end,
})

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

-- >>> COLORS
local function cs_gruvsimple()
  if g.highlights_loaded then
    return
  end

  vim.cmd("hi clear")

  local background = "#1d2021"
  local foreground = "#d4be98"
  local accent = "#e78a4e"
  local grey = "#7c6f64"
  local dark_grey = "#5A524C"
  local black = "#32302f"
  local red = "#ea6962"
  local green = "#a9b665"
  local yellow = "#d8a657"
  local blue = "#7daea3"
  local magenta = "#d3869b"
  local cyan = "#89b482"
  local white = "#ddc7a1"

  g.terminal_color_0 = black
  g.terminal_color_1 = red
  g.terminal_color_2 = green
  g.terminal_color_3 = yellow
  g.terminal_color_4 = blue
  g.terminal_color_5 = magenta
  g.terminal_color_6 = cyan
  g.terminal_color_7 = white
  g.terminal_color_8 = black
  g.terminal_color_9 = red
  g.terminal_color_10 = green
  g.terminal_color_11 = yellow
  g.terminal_color_12 = blue
  g.terminal_color_13 = magenta
  g.terminal_color_14 = cyan
  g.terminal_color_15 = white

  local highlights = {
    -- UI
    Added = { fg = green },
    Changed = { fg = blue },
    ColorColumn = { bg = black },
    Conceal = {},
    CurSearch = { link = "Search" },
    Cursor = { bg = black },
    CursorLine = { bg = black },
    DiagnosticError = { fg = red },
    DiagnosticHint = { fg = blue },
    DiagnosticInfo = { fg = cyan },
    DiagnosticOk = { fg = green },
    DiagnosticWarn = { fg = yellow },
    DiagnosticUnderlineError = { sp = red, undercurl = true },
    DiagnosticUnderlineHint = { sp = blue, undercurl = true },
    DiagnosticUnderlineInfo = { sp = cyan, undercurl = true },
    DiagnosticUnderlineOk = { sp = green, undercurl = true },
    DiagnosticUnderlineWarn = { sp = yellow, undercurl = true },
    DiffAdd = { link = "Added" },
    DiffChange = { link = "Changed" },
    DiffDelete = { link = "Removed" },
    DiffText = { link = "Normal" },
    DiffLine = { fg = blue, bold = true },
    DiffFile = { fg = foreground, bold = true },
    Directory = { fg = blue },
    EndOfBuffer = { fg = grey, bg = nil },
    Error = { link = "ErrorMsg" },
    ErrorMsg = { fg = red, bold = true },
    FloatBorder = { fg = foreground, bg = black },
    FoldColumn = { link = "SignColumn" },
    Folded = { link = "Comment" },
    Hint = { link = "HintMsg" },
    HintMsg = { fg = blue, bold = true },
    IncSearch = { link = "Search" },
    Info = { link = "ErrorMsg" },
    InfoMsg = { fg = cyan, bold = true },
    LineNr = { bold = true },
    LineNrAbove = { fg = grey, bold = false },
    LineNrBelow = { link = "LineNrAbove" },
    MatchParen = { bg = dark_grey, bold = true },
    ModeMsg = { link = "Normal", bold = true },
    MoreMsg = { link = "Normal", bold = true },
    Normal = { fg = foreground, bg = nil },
    NormalFloat = { fg = foreground, bg = black },
    Pmenu = { bg = black, fg = foreground },
    PmenuKind = { fg = blue },
    PmenuKindSel = { bg = dark_grey, fg = blue, bold = true },
    PmenuSbar = { bg = black, fg = foreground },
    PmenuSel = { bg = dark_grey, fg = white, bold = true },
    PmenuThumb = { bg = black, fg = foreground },
    Question = { fg = yellow, bold = true },
    QuickFixLine = { fg = yellow },
    Removed = { fg = green },
    Search = { bg = yellow, fg = background },
    SignColumn = { fg = grey, bg = background },
    SpecialKey = { fg = blue },
    Title = { link = "NormalFloat" },
    Todo = { fg = accent },
    Visual = { bg = dark_grey },
    Warning = { link = "WarningMsg" },
    WarningMsg = { fg = yellow, bold = true },
    WildMenu = { link = "Pmenu" },

    -- statusline
    LinePrimaryBlock = { fg = black, bg = background },
    LineSecondaryBlock = { fg = blue, bg = background },
    LineError = { link = "Error" },
    LineHint = { link = "Hint" },
    LineInfo = { link = "Info" },
    LineWarning = { link = "Warning" },
    StatusLine = { fg = white, bg = black, bold = true },
    StatusLineNC = { fg = grey, bg = background },
    StatusLineTab = { link = "StatusLine" },

    -- Syntax
    Boolean = { link = "Constant" },
    Character = { link = "String" },
    Comment = { fg = grey, italic = true },
    Constant = { fg = yellow },
    Delimiter = { link = "Normal" },
    Function = { fg = cyan },
    Identifier = { fg = foreground },
    Include = { fg = accent, bold = true },
    InstanceVariable = { fg = magenta },
    Keyword = { fg = red },
    Label = { link = "Keyword" },
    Macro = { fg = accent },
    NonText = { link = "Normal" },
    Number = { link = "Constant" },
    Operator = { fg = accent },
    PreProc = { link = "Include" },
    Special = { link = "Normal" },
    Statement = { link = "Keyword" },
    String = { fg = green },
    Symbol = { link = "Normal" },
    Type = { link = "Constant" },

    -- Treesitter
    ["@variable"] = { link = "Normal" },
    ["@string.special.url"] = { fg = blue, underline = true },
    TreesitterContextBottom = { underline = true },
    TreesitterContextLineNumber = { link = "LineNrAbove" },
    ["@lsp.type.comment"] = {},
    ["@markup.heading"] = {},
    ["@markup.link"] = {},

    -- HTML (many markdown things link to HTML)
    htmlH1 = { fg = red, bold = true },
    htmlH2 = { fg = accent, bold = true },
    htmlH3 = { fg = yellow, bold = true },
    htmlH4 = { fg = green, bold = true },
    htmlH5 = { fg = cyan, bold = true },
    htmlH6 = { fg = blue, bold = true },
    htmlLink = { fg = blue, underline = true },

    -- Markdown
    markdownH1Delimiter = { link = "markdownH1" },
    markdownH2Delimiter = { link = "markdownH2" },
    markdownH3Delimiter = { link = "markdownH3" },
    markdownH4Delimiter = { link = "markdownH4" },
    markdownH5Delimiter = { link = "markdownH5" },
    markdownH6Delimiter = { link = "markdownH6" },
    markdownLink = { fg = green, underline = true },
    markdownUrl = { link = "htmlLink" },
    markdownCode = { link = "markdownCodeBlock" },
    markdownCodeDelimiter = { link = "markdownCodeBlock" },
    markdownCodeBlock = { link = "Comment" },
    markdownListMarker = { link = "Keyword" },
    markdownOrderedListMarker = { link = "Keyword" },
  }

  for group, opts in pairs(highlights) do
    api.nvim_set_hl(0, group, opts)
  end

  g.highlights_loaded = true
end

cs_gruvsimple()
