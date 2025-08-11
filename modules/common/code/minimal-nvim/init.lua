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

local function is_git_repo()
  _ = fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
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
opt.undofile = true

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
    create_cmd("Tform", function(opts)
      cmd(":silent ! shellharden --replace " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "c", "cpp" },
  callback = function()
    create_cmd("Tform", function(opts)
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
    create_cmd("Tform", function(opts)
      cmd(":silent ! prettier -w " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    create_cmd("Tform", function(opts)
      cmd(":silent ! stylua " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "nix" },
  callback = function()
    create_cmd("Tform", function(opts)
      cmd(":silent ! nixpkgs-fmt " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    create_cmd("Tform", function(opts)
      local root_dir = find_root({ "pyproject.toml" })
      cmd(":silent ! poetry --project " .. root_dir .. " run black " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "rust" },
  callback = function()
    create_cmd("Tform", function(opts)
      cmd(":silent ! cargo fmt " .. opts.fargs[1])
    end, { nargs = 1, desc = "Format file" })
  end,
})

create_autocmd("FileType", {
  pattern = { "zig" },
  callback = function()
    create_cmd("Tform", function(opts)
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
keymap("]c", ":cnext<cr>", "cnext")
keymap("[c", ":cprev<cr>", "cprev")
keymap("<F8>", ":cnext<cr>", "cnext")
keymap("<F7>", ":cprev<cr>", "cprev")
keymap("<F6>", ":cclose<cr>", "cprev")
keymap("<leader>fd", ":Explore<cr>", "netrw")
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
opt.laststatus = 3

o.foldenable = true
o.foldlevel = 99
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldtext = ""
opt.foldcolumn = "0"
opt.fillchars:append({ fold = " " })

-- >>> NAVIGATION
g.netrw_banner = 0
-- g.netrw_browse_split = 4
-- g.netrw_altv = 1
g.netrw_liststyle = 3

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
keymap("<leader>ff", file_search, "file search")

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
          abbr = #abbr > 15 and abbr:sub(1, 14) .. "…" or abbr

          local menu = item.detail or ""
          menu = #menu > 15 and menu:sub(1, 14) .. "…" or menu

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

-- >>> IDEAS
-- taken from Vitaly Kurin on Youtube:
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

-- use these to dump the output of an external command into a scratchbuffer
--   - git blame, diff, ...
--   - grep in file
--   - linting (which means I can use this for Tcheck)
-- and if it's in qf format, you can manually edit the list and dump that into
-- the qflist

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

create_cmd("Tgrep", function(opts)
  if is_git_repo() then
    extcmd_to_scratch({
      "git",
      "grep",
      "-nE",
      opts.args,
    }, true)
  else
    extcmd_to_scratch({
      "rg",
      "--vimgrep",
      "--no-column",
      "-ne",
      opts.args,
    }, true)
  end
end, { nargs = "+", desc = "Format file" })

create_cmd("Tscratch", function(opts)
  if is_git_repo() then
    extcmd_to_scratch({
      "git",
      "grep",
      "-nE",
      opts.args,
    }, false)
  else
    extcmd_to_scratch({
      "rg",
      "--vimgrep",
      "--no-column",
      "-e",
      opts.args,
    }, false)
  end
end, { nargs = "+", desc = "Format file" })

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

-- keymap("<leader>;c", function() extcmd_to_scratch({ "ruff", "check", fn.expand("%") }, true) end)
