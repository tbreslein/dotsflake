-- [nfnl] _init.fnl
local core = require("nfnl.core")
local assoc = core.assoc
local empty_3f = core["empty?"]
local nil_3f = core["nil?"]
local table_3f = core["table?"]
local string_3f = core["string?"]
local function_3f = core["function?"]
local function not_nil_3f(x)
  return not nil_3f(x)
end
local function not_empty_3f(x)
  return not empty_3f(x)
end
local function pumvisible_3f()
  return (tonumber(vim.fn.pumvisible) ~= 0)
end
local function keymap(lhs, rhs, opts, mode)
  local opts0
  if string_3f(opts) then
    opts0 = {desc = opts}
  else
    opts0 = vim.tbl_extend("error", (opts or {}), {noremap = true, silent = true})
  end
  local lhs0
  if table_3f(lhs) then
    lhs0 = lhs
  else
    lhs0 = {lhs}
  end
  for _, l in ipairs(lhs0) do
    vim.keymap.set((mode or "n"), l, rhs, opts0)
  end
  return nil
end
local function git_repo_3f()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return (vim.v.shell_error == 0)
end
local function feedkeys(keys)
  return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end
local function fzf_search(extcmd, exit_fn)
  local vapi = vim.api
  local vfn = vim.fn
  local width
  if ((vim.o.columns - 2) > 120) then
    width = 120
  else
    width = (vim.o.columns - 2)
  end
  local height = 12
  local buf = vapi.nvim_create_buf(false, true)
  local file = vfn.tempname()
  vapi.nvim_set_option_value("bufhidden", "wipe", {buf = buf})
  vapi.nvim_set_option_value("modifiable", true, {buf = buf})
  keymap("<esc>", ":bd!<cr>", {desc = "exit", buffer = buf}, "i")
  vapi.nvim_open_win(buf, true, {relative = "editor", style = "minimal", noautocmd = true, width = width, height = height, col = math.min(((vim.o.columns - width) / 2)), row = (vim.o.lines - height)})
  vapi.nvim_command("startinsert!")
  local function _4_()
    do
      local f = io.open(file, "r")
      local function close_handlers_12_(ok_13_, ...)
        f:close()
        if ok_13_ then
          return ...
        else
          return error(..., 0)
        end
      end
      local function _6_()
        return exit_fn(f:read("*all"))
      end
      local _8_
      do
        local t_7_ = _G
        if (nil ~= t_7_) then
          t_7_ = t_7_.package
        else
        end
        if (nil ~= t_7_) then
          t_7_ = t_7_.loaded
        else
        end
        if (nil ~= t_7_) then
          t_7_ = t_7_.fennel
        else
        end
        _8_ = t_7_
      end
      local or_12_ = _8_ or _G.debug
      if not or_12_ then
        local function _13_()
          return ""
        end
        or_12_ = {traceback = _13_}
      end
      close_handlers_12_(_G.xpcall(_6_, or_12_.traceback))
    end
    return os.remove(file)
  end
  return vfn.jobstart((extcmd .. " > " .. file), {term = true, on_exit = _4_})
end
local function file_search()
  local extcmd
  if git_repo_3f() then
    extcmd = "git ls-files"
  else
    extcmd = "find . type -f"
  end
  local function _15_(stdout)
    local selected, _ = stdout:gsub("\n", "")
    if not_empty_3f(selected) then
      vim.cmd("bd!")
      return vim.cmd(("e " .. selected))
    else
      return nil
    end
  end
  return fzf_search((extcmd .. " | fzf --height=12 --reverse --border=none"), _15_)
end
local function scratch_to_qf()
  local vapi = vim.api
  local vfn = vim.fn
  local bufnr = vapi.nvim_get_current_buf()
  local items = {}
  for _, line in ipairs(vapi.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if not_empty_3f(line) then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if (filename and lnum) then
        table.insert(items, {filename = filename, lnum = tonumber(lnum), text = text})
      else
        local lnum0, text0 = line:match("^(%d+):(.*)$")
        if (lnum0 and text0) then
          table.insert(items, {filename = vfn.bufname(vfn.bufnr("#")), lnum = tonumber(lnum0), text = text0})
        else
          table.insert(items, {filename = vfn.fnamemodify(line, ":p"), lnum = 1, text = ""})
        end
      end
    else
    end
    vapi.nvim_buf_delete(bufnr, {force = true})
    vfn.setqflist(items, "r")
    vim.cmd("copen | cc")
  end
  return nil
end
local function extcmd_to_scratch(extcmd, quickfix_3f)
  local output
  if table_3f(extcmd) then
    output = vim.fn.systemlist(extcmd)
  else
    output = {vim.fn.system, vim.split(extcmd, "\n")}
  end
  if not_empty_3f(output) then
    vim.cmd("vnew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, output)
    assoc(vim.bo, "buftype", "nofile", "bufhidden", "wipe", "swapfile", false)
    if quickfix_3f then
      return scratch_to_qf
    else
      return nil
    end
  else
    return nil
  end
end
local function find_root(new_markers)
  local markers = {".git/"}
  vim.list_extend(markers, new_markers)
  return vim.fs.dirname(vim.fs.find(markers, {path = vim.fn.expand("%:p :h"), upward = true})[1])
end
do
  local tabstop = 4
  local undodir = (os.getenv("HOME") .. "/.local/share/vim/undodir")
  local g = {mapleader = " ", maplocalleader = ",", netrw_banner = 0, netrw_liststyle = 3}
  local opts = {mouse = "a", tabstop = tabstop, shiftwidth = tabstop, softtabstop = tabstop, wildoptions = {"fuzzy", "pum", "tagfile"}, splitbelow = true, undofile = true, undodir = undodir, guicursor = "", number = true, relativenumber = true, winborder = "single", colorcolumn = "80", signcolumn = "no", cursorline = true, cursorlineopt = "screenline", scrolloff = 5, laststatus = 3, foldenable = true, foldlevel = 99, foldmethod = "expr", foldexpr = "v:lua.vim.treesitter.foldexpr()", foldtext = "", foldcolumn = "0", completeopt = {"fuzzy", "menu", "menuone", "noselect", "noinsert", "popup", "preview"}, pumheight = 20, pumwidth = 45, confirm = false, splitright = false, swapfile = false}
  for k, v in pairs(g) do
    assoc(vim.g, k, v)
  end
  for k, v in pairs(opts) do
    assoc(vim.opt, k, v)
  end
  vim.diagnostic.config({virtual_text = {current_line = true}})
  vim.opt.fillchars:append({fold = " "})
  if (vim.fn.isdirectory(undodir) == 0) then
    vim.fn.mkdir(undodir, "p")
  else
  end
end
local ft_settings
local function _24_()
  return assoc(vim.bo, "expandtab", false)
end
local function _25_()
  return ("poetry --project " .. find_root({"pyproject.toml"}))
end
local function _26_()
  return keymap("q", ":q<cr>")
end
local function _27_()
  assoc(vim.bo, "textwidth", 72)
  return assoc(vim.wo, "colorcolumn", "+0", "spell", true)
end
ft_settings = {{pattern = "fennel", tform = "fnlfmt --fix"}, {pattern = {"c", "cpp"}, tform = "clang-format -i"}, {pattern = "go", misc = _24_}, {pattern = "python", tform = _25_}, {pattern = "rust", tform = "cargo fmt"}, {pattern = "zig", tform = "zig fmt"}, {pattern = {"bash", "sh"}, tform = "shellharden"}, {pattern = "lua", tform = "stylua"}, {pattern = "nix", tform = "nixpkgs-fmt"}, {pattern = {"javascript", "javascriptreact", "typescript", "typescriptreact", "html", "css", "scss", "json", "jsonc", "markdown"}, tform = "prettier -w"}, {pattern = {"man", "help"}, misc = _26_}, {pattern = "gitcommit", misc = _27_}}
do
  local km
  local function _28_()
    return extcmd_to_scratch({"git", "diff"})
  end
  local function _29_()
    return extcmd_to_scratch({"git", "blame", vim.fn.expand("%")})
  end
  local function _30_()
    local function _31_(_2410)
      if _2410() then
        return vim.cmd(("Tgrep " .. _2410))
      else
        return nil
      end
    end
    return vim.ui.input({prompt = "> "}, _31_)
  end
  local function _33_()
    local function _34_(_2410)
      if _2410() then
        return vim.cmd(("Tscratch " .. _2410))
      else
        return nil
      end
    end
    return vim.ui.input({prompt = "> "}, _34_)
  end
  local function _36_()
    if pumvisible_3f() then
      return feedkeys("<c-n>")
    elseif empty_3f(vim.bo.omnifunc) then
      return feedkeys("<c-x><c-n>")
    else
      return feedkeys("<c-x><c-o>")
    end
  end
  local function _38_()
    if pumvisible_3f() then
      return feedkeys("<c-p>")
    elseif empty_3f(vim.bo.omnifunc) then
      return feedkeys("<c-x><c-p>")
    else
      return feedkeys("<c-x><c-o>")
    end
  end
  local function _40_()
    if pumvisible_3f() then
      return "<c-e>"
    else
      return "<c-i>"
    end
  end
  km = {{"<leader>w", ":w<cr>"}, {"<leader>a", ":e #<cr>", "switch to alternate file"}, {"<leader>A", ":sf #<cr>", "split find alternate file"}, {"<leader>n", ":set relativenumber!<cr>"}, {"<esc>", ":noh<cr>", "remove hlsearch"}, {"n", "nzzzv"}, {"N", "Nzzzv"}, {"*", "*zzzv"}, {"#", "#zzzv"}, {"g*", "g*zzzv"}, {"g#", "g#zzzv"}, {"<c-d>", "<c-d>zz"}, {"<c-u>", "<c-u>zz"}, {"P", "\"_dP", "paste over something without overwriting register", "v"}, {"<leader>d", "\"_d", "d without overwriting register", {"n", "v", "x"}}, {"<leader>x", "\"_x", "x without overwriting register", {"n", "v", "x"}}, {"Y", "yg$"}, {"<leader>y", "\"+y", "yank into clipboard", {"n", "v"}}, {"<leader>Y", "\"+yg$", "yank till end of line into clipboard", "n"}, {"<leader>p", "\"+p", "paste from clipboard", {"n", "v"}}, {"J", "mzJ`z"}, {"<m-j>", ":m .+1<cr>==", "move line down", "n"}, {"<m-k>", ":m .+1<cr>==", "move line up", "n"}, {"<m-j>", ":m '>+1<cr>gv=gv", "move block down", "v"}, {"<m-k>", ":m '<-2<cr>gv=gv", "move block up", "v"}, {"<", "<gv", "de-indent", {"n", "v"}}, {">", ">gv", "indent", {"n", "v"}}, {"jk", "<c-\\><c-n>", "normal mode", "t"}, {"<c-h>", "<c-w>h"}, {"<c-j>", "<c-w>j"}, {"<c-k>", "<c-w>k"}, {"<c-l>", "<c-w>l"}, {"<m-H>", "<cmd>vertical resize -2<cr>"}, {"<m-J>", "<cmd>resize +2<cr>"}, {"<m-K>", "<cmd>resize -2<cr>"}, {"<m-L>", "<cmd>vertical resize +2<cr>"}, {"<c-s><c-s>", ":split<cr>"}, {"<c-s><c-v>", ":vsplit<cr>"}, {{"]c", "<F8>"}, ":cnext<cr>"}, {{"[c", "<F7>"}, ":cprev<cr>"}, {"<F6>", ":cclose<cr>"}, {"<leader>fd", ":Ex<cr>"}, {"<leader>ff", file_search}, {"<leader>x", scratch_to_qf}, {"<leader>ggd", _28_, "send git diff to scratch"}, {"<leader>ggb", _29_, "send git blame to scratch"}, {"<leader>sf", _30_, "grep and send to qf"}, {"<leader>ss", _33_, "grep and send to scratch"}, {"<leader>;f", ":Tform %<cr>", "run formatter"}, {"<leader>;t", ":Ttest<cr>", "run tests"}, {"<leader>;c", ":Tcheck<cr>", "run lints"}, {"<leader>;m", ":make<cr>", "run makeprg"}, {"<leader>mp", "mP", "mark P"}, {"<leader>mf", "mF", "mark F"}, {"<leader>mw", "mW", "mark W"}, {"<leader>mq", "mQ", "mark Q"}, {"<leader>mb", "mB", "mark B"}, {"<m-p>", "`P", "goto mark P"}, {"<m-f>", "`F", "goto mark F"}, {"<m-w>", "`W", "goto mark W"}, {"<m-q>", "`Q", "goto mark Q"}, {"<m-b>", "`B", "goto mark B"}, {"<c-n>", _36_, "trigger/next completion", "i"}, {"<c-e>", _38_, "trigger/prev completion", "i"}, {"<c-i>", _40_, {expr = true, desc = "cancel completion"}, "i"}, {"<c-u>", "<c-x><c-n>", "buffer completions", "i"}}
  for _, v in ipairs(km) do
    keymap(v[1], v[2], v[3], v[4])
  end
end
local lspmaps = {gs = vim.diagnostic.setqflist, gS = vim.diagnostic.setloclist, gh = vim.diagnostic.open_float, gd = vim.lsp.buf.definition, gD = vim.lsp.buf.declaration, gwd = ":vsplit | lua vim.lsp.buf.definition()<cr>", gwD = ":vsplit | lua vim.lsp.buf.declaration()<cr>", gt = vim.lsp.buf.type_definition, gi = vim.lsp.buf.implementation}
do
  local create_au = vim.api.nvim_create_autocmd
  local create_cmd = vim.api.nvim_create_user_command
  local function _42_(_241)
    if git_repo_3f() then
      return extcmd_to_scratch({"git", "grep", "-nE", _241.args}, not _241.bang)
    else
      return extcmd_to_scratch({"rg", "--vimgrep", "--no-column", "-ne", _241.args}, not _241.bang)
    end
  end
  create_cmd("Tgrep", _42_, {nargs = "+", bang = true, desc = "grep recursively; bang sends the results to a scratch buffer"})
  for _, ft in ipairs(ft_settings) do
    local function _44_()
      if not_nil_3f(ft.tform) then
        local tform
        local _45_
        if function_3f(ft.tform) then
          _45_ = ft.tform()
        else
          _45_ = ft.tform
        end
        tform = (":silent !" .. _45_)
        local function _47_(_241)
          return vim.cmd((tform .. " " .. _241.fargs[1]))
        end
        create_cmd("Tform", _47_, {nargs = 1, desc = "Format file"})
      else
      end
      if not_nil_3f(ft.misc) then
        return ft.misc()
      else
        return nil
      end
    end
    create_au("FileType", {pattern = ft.pattern, callback = _44_})
  end
end
do
  local vapi = vim.api
  local set_cursor = vapi.nvim_win_set_cursor
  local usergroup = vapi.nvim_create_augroup("UserConfig", {})
  local gitgroup = vapi.nvim_create_augroup("Git", {})
  local au
  local function _50_()
    local mark = vapi.nvim_buf_get_mark(0, "\"")
    local lcount = vapi.nvim_buf_line_count(0)
    if ((mark[1] > 0) and (mark[1] <= lcount)) then
      return pcall(set_cursor, 0, mark)
    else
      return nil
    end
  end
  local function _52_()
    local dir = vim.fn.expand("<afile>:p:h")
    if (vim.fn.isdirectory(dir) == 0) then
      return vim.fn.mkdir(dir, "p")
    else
      return nil
    end
  end
  local function _54_()
    return vim.bo.filetype("markdown")
  end
  local function _55_()
    assoc(vim.wo, "spell", true)
    set_cursor(0, {1, 0})
    if empty_3f(vim.fn.getline(1)) then
      return vim.cmd("startinsert!")
    else
      return nil
    end
  end
  au = {{e = "TextYankPost", g = usergroup, c = vim.highlight.on_yank}, {e = "BufReadPost", g = usergroup, c = _50_}, {e = "BufWritePre", g = usergroup, c = _52_}, {e = {"BufEnter", "BufNewFile", "BufRead"}, p = "*.mdx", c = _54_}, {e = "BufEnter", g = gitgroup, p = "COMMIT_EDITMSG", c = _55_}}
  for _, x in ipairs(au) do
    local _58_
    do
      local t_57_ = x.p
      _58_ = t_57_
    end
    local function _59_()
      return x.c()
    end
    vapi.nvim_create_autocmd(x.e, {group = x.g, pattern = _58_, callback = _59_})
  end
end
local function on_lsp_attach(ev)
  local vlsp = vim.lsp
  local cenable = vlsp.completion.enable
  local snip = vim.snippet
  local bufnr = ev.buf
  local client = vlsp.get_client_by_id(ev.data.client_id)
  vim["bo"][bufnr]["omnifunc"] = "v:lua.vim.lsp.omnifunc"
  if (client and client:supports_method("textDocument/completion")) then
    local function _60_(item)
      local abbr = item.label
      abbr = abbr:gsub("%b()")
      abbr = abbr:gsub("%b{}")
      abbr = (abbr:match("[%w_.]+.*") or abbr)
      if (#abbr > 15) then
        abbr = abbr:sub(1, 14)
      else
      end
      local menu = (item.detail or "")
      if (#menu > 15) then
        menu = menu:sub(1, 14)
      else
      end
      return {abbr = abbr, menu = menu}
    end
    cenable(true, ev.data.client_id, bufnr, {convert = _60_})
  else
  end
  for k, v in pairs(lspmaps) do
    keymap(k, v, {buffer = bufnr})
  end
  local function _64_()
    if snip.active({direction = 1}) then
      return snip.jump(1)
    else
      return feedkeys("<tab>")
    end
  end
  keymap("<tab>", _64_, {buffer = bufnr}, {"i", "s"})
  local function _66_()
    if snip.active({direction = -1}) then
      return snip.jump(-1)
    else
      return feedkeys("<s-tab>")
    end
  end
  keymap("<s-tab>", _66_, {buffer = bufnr}, {"i", "s"})
  return keymap("<bs>", "<c-o>s", {buffer = bufnr}, "s")
end
vim.api.nvim_create_autocmd("LspAttach", {callback = on_lsp_attach})
local function pyright_set_python_path(path)
  local clients = vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf(), name = "pyright"})
  for _, client in ipairs(clients) do
    if client.settings() then
      client.settings.python = vim.tbl_deep_extend("force", client.settings.python, {pythonPath = path})
    else
      client.settings.config = vim.tbl_deep_extend("force", client.config.settings, {python = {pythonPath = path}})
    end
  end
  return nil
end
local function pyright_attach(client, bufnr)
  local create_buf_cmd = vim.api.nvim_buf_create_user_command
  local function _69_()
    return client:exe_cmd({command = "pyright.organizeimports", arguments = {vim.uri_from_bufnr(bufnr)}})
  end
  create_buf_cmd(bufnr, "LspPyrightOrganizeImports", _69_, {nargs = 1, desc = "organize imports", complete = "file"})
  return create_buf_cmd(bufnr, "LspPyrightSetPythonPath", pyright_set_python_path, {nargs = 1, desc = "Reconfigure pyright with the provided python path", complete = "file"})
end
local function pyright_new_config(config, root_dir)
  local env = vim.trim(vim.fn.system(("cd \"" .. (root_dir or ".") .. "\" | ; poetry env info --executable 2>/dev/null")))
  if not_empty_3f(env) then
    config.settings.python.pythonPath = env
    return nil
  else
    return nil
  end
end
local vlsp = vim.lsp
local get_rt_file = vim.api.nvim_get_runtime_file
local configs = {pyright = {cmd = {"pyright-langserver", "--stdio"}, filetypes = {"python"}, root_markers = {"pyproject.toml", ".git"}, settings = {python = {analysis = {autoSearchPaths = true, useLibraryCodeForTypes = true, diagnosticMode = "openFilesOnly"}}}, on_attach = pyright_attach, on_new_config = pyright_new_config}, lua_ls = {cmd = {"lua-language-server"}, filetypes = {"lua"}, root_markers = {".git"}, settings = {Lua = {workspace = {library = get_rt_file("", true)}}}}, rust_analyzer = {cmd = {"rust-analyzer"}, filetypes = {"rust"}, root_markers = {"Cargo.toml", ".git"}}}
for k, v in pairs(configs) do
  vlsp.enable(k)
  vlsp.config(k, v)
end
return nil
