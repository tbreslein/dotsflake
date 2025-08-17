vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- >>> PREAMBLE {{{3
vim.g.uname = vim.uv.os_uname().sysname
vim.g.is_darwin = vim.g.uname == "Darwin"
vim.g.is_linux = vim.g.uname == "Linux"
if vim.g.is_darwin then
  vim.g.open_cmd = "open"
else
  vim.g.open_cmd = "xdg-open"
end

local roots = vim
  .iter({
    c = { "makefile" },
    python = {
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      "pyrightconfig.json",
    },
    nix = { "flake.nix" },
    rust = { "Cargo.toml" },
    javascript = { "package.json" },
    zig = { "build.zig" },
  })
  :fold({}, function(acc, k, v)
    acc[k] = vim.list_extend(v, { ".git" })
    return acc
  end)

local function mkdirp(dir)
  if vim.fn.isdirectory == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

local function create_keymap(lhs, v)
  local function f(rhs, opts, mode)
    opts = type(opts) == "string" and { desc = opts }
      or vim.tbl_extend("error", opts --[[@as table]], { noremap = true, silent = true })
    vim.keymap.set(mode or "n", lhs, rhs, opts)
  end

  if vim.islist(v) then
    f(v[1], v[2], v[3])
  else
    for mode, _v in pairs(v) do
      f(_v[1], _v[2], mode)
    end
  end
end

-- taken from Vitaly Kurin on Youtube:
-- use these to dump the output of an external command into a scratchbuffer
--   - git blame, diff, ...
--   - grep in file
--   - linting (which means I can use this for Tcheck)
-- and if it's in qf format, you can manually edit the list and dump that into
-- the qflist
local function scratch_to_quickfix()
  local bufnr = vim.api.nvim_get_current_buf()
  local items = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    if line ~= "" then
      local filename, lnum, text = line:match("^([^:]+):(%d+):(.*)$")
      if filename and lnum then
        -- used for grep filename:line:text
        table.insert(items, { filename = filename, lnum = tonumber(lnum), text = text })
      else
        lnum, text = line:match("^(%d+):(.*)$")
        if lnum and text then
          -- used for current buffer grep
          table.insert(items, { filename = vim.fn.bufname(vim.fn.bufnr("#")), lnum = tonumber(lnum), text = text })
        else
          -- only filenames
          table.insert(items, { filename = vim.fn.fnamemodify(line, ":p"), lnum = 1, text = "" })
        end
      end
    end
  end
  vim.api.nvim_buf_delete(bufnr, { force = true })
  vim.fn.setqflist(items, "r")
  vim.cmd("copen | cc")
end

local function extcmd_to_scratch(extcmd, quickfix, cwd)
  local function on_exit(out)
    if out.stdout == nil or #out.stdout == 0 then
      return
    end

    vim.cmd("vnew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(out.stdout, "\n", { trimempty = true }))
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false

    if quickfix then
      scratch_to_quickfix()
    end
  end

  -- NOTE: the schedule_wrap ensures that the wrapped function executes back on
  -- the main thread. vim.system runs async, and in that context you cannot run
  -- things like vim.cmd and vim.api.*, because those assume that they are
  -- calleed on the main thread
  vim.system(extcmd, { cwd = cwd, text = true }, vim.schedule_wrap(on_exit))
end

local function extcmd_in_floatterm(extcmd, exit_fn)
  local width = vim.o.columns - 2
  if width > 120 then
    width = 120
  end
  local height = 12

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  create_keymap("<esc>", { ":bd!<cr>", { desc = "exit", buffer = buf }, "i" })

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    noautocmd = true,
    width = width,
    height = height,
    col = math.min((vim.o.columns - width) / 2),
    row = vim.o.lines - height,
  })
  local file = vim.fn.tempname()
  vim.api.nvim_command("startinsert!")

  vim.fn.jobstart(extcmd .. " > " .. file, {
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

local function create_command(c)
  vim.api.nvim_create_user_command(c[1], c[2], c[3])
end

local function create_aucmd(au)
  vim.api.nvim_create_autocmd(au.event, {
    pattern = au.pattern,
    group = au.group,
    callback = au.callback,
  })
end

local ft_group = vim.api.nvim_create_augroup("UserFT", {})

local function create_ft_aucmd(k, v)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.split(k, "|", { trimempty = true }),
    group = ft_group,
    callback = function()
      if v.format ~= nil then
        local cmd = ":silent ! "
        if type(v.format) == "function" then
          cmd = cmd .. v.format()
        else
          cmd = cmd .. v.format
        end
        vim.api.nvim_create_user_command("Tform", function(opts)
          vim.cmd(cmd .. " " .. opts.fargs[1])
        end, { nargs = 1, desc = "run formatter" })
      end

      -- if v.check ~= nil then
      --   local cmd_str = ""
      --   if type(v.check) == "function" then
      --     cmd_str = cmd_str .. v.check()
      --   else
      --     cmd_str = cmd_str .. v.check
      --   end
      --   vim.api.nvim_create_user_command("Tcheck", function()
      --     extcmd_to_scratch(cmd_str, true)
      --   end, { nargs = 0, desc = "run linter" })
      -- end

      if v.test ~= nil then
      end

      if v.make ~= nil then
      end

      if v.misc ~= nil then
        v.misc()
      end

      -- for Tcheck, maybe use extcmd_to_scratch?
      -- keymap("<leader>;c", function() extcmd_to_scratch({ "ruff", "check", fn.expand("%") }, true) end)
    end,
  })
end

local function create_lsp_config(ls_server, ls_config)
  vim.lsp.enable(ls_server)
  vim.lsp.config(ls_server, ls_config)
end

local function set_hl(hl_group, hl_config)
  vim.api.nvim_set_hl(0, hl_group, hl_config)
end

local function pumvisible()
  return tonumber(vim.fn.pumvisible()) ~= 0
end

local function feedkeys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

local function find_root(additional_markers)
  return vim.fs.root(0, { additional_markers, ".git/" })
end

local function is_git_repo()
  _ = vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

local function file_search()
  local extcmd = ""
  if is_git_repo() then
    extcmd = "git ls-files"
  else
    extcmd = "find . -type f"
  end
  extcmd_in_floatterm(extcmd .. " | fzf --height=12 --reverse --border=none", function(stdout)
    local selected, _ = stdout:gsub("\n", "")
    if #selected > 0 then
      vim.cmd("bd!")
      vim.cmd("e " .. selected)
    end
  end)
end

-- >>> SETTINGS {{{1
-- >>> PACK {{{2
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
})
require("nvim-treesitter.configs").setup({
  highlight = { enable = true, additional_vim_regex_highlighting = { "markdown" } },
  ensure_installed = "all",
  ignore_install = { "ipkg" },
  sync_install = true,
  auto_install = true,
  indent = { enable = true },
})
require("treesitter-context").setup({ multiline_threshold = 2 })

-- >>> OPTS {{{2
vim.opt.mouse = "a"
local tabstop = 4
vim.opt.tabstop = tabstop
vim.opt.shiftwidth = tabstop
vim.opt.softtabstop = tabstop
vim.opt.wildoptions = { "fuzzy", "pum", "tagfile" }
vim.opt.confirm = false
vim.opt.splitbelow = true
vim.opt.splitright = false
vim.opt.swapfile = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/vim/undodir"
vim.opt.undofile = true
mkdirp(vim.opt.undodir)

vim.o.background = "dark"
vim.opt.winborder = "single"
vim.opt.guicursor = ""
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.colorcolumn = "80"
vim.opt.signcolumn = "no"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "screenline"
vim.opt.scrolloff = 5
vim.opt.laststatus = 3

vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldcolumn = "0"
-- vim.opt.fillchars:append({ fold = " " })

vim.g.netrw_banner = 0
-- vim.g.netrw_browse_split = 4
-- vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3

-- >>> COMPLETION
vim.opt.completeopt = { "fuzzy", "menu", "menuone", "noselect", "noinsert", "popup", "preview" }
vim.opt.pumheight = 20
vim.opt.pumwidth = 45

vim.g.grepprg = "git grep -nE"
vim.diagnostic.config({ virtual_text = { current_line = true } })

-- >>> KEYMAPS {{{2
vim
  .iter({
    ["<leader>w"] = { ":w<cr>", "write" },
    ["<leader>q"] = { ":q<cr>", "quit" },
    ["jk"] = { "<C-\\><C-n>", "normal mode", "t" },
    ["<leader>a"] = { ":e #<cr>", "switch to alternate file", { "n", "x", "v" } },
    ["<leader>A"] = { ":sf #<cr>", "split find alternate file", { "n", "x", "v" } },
    ["<leader>n"] = { ":set relativenumber!<cr>", "toggle relative lines" },
    ["<esc>"] = { ":noh<cr>", "remove hlsearch" },
    ["n"] = { "nzzzv", "center after n" },
    ["N"] = { "Nzzzv", "center after N" },
    ["*"] = { "*zz", "center after *" },
    ["#"] = { "#zz", "center after #" },
    ["g*"] = { "g*zz", "center after g*" },
    ["g#"] = { "g#zz", "center after g#" },
    ["<c-d>"] = { "<c-d>zz", "center after c-d" },
    ["<c-u>"] = { "<c-u>zz", "center after c-u" },
    ["P"] = { [["_dP]], "paste without overwriting register", "v" },
    ["<leader>d"] = { [["_d]], "d without overwriting register", { "n", "v" } },
    ["<leader>x"] = { [["_x]], "x without overwriting register", { "n", "x", "v" } },
    ["Y"] = { "yg$", "yank till end of line" },
    ["<leader>y"] = { [["+y]], "yank into clipboard", "v" },
    ["<leader>Y"] = { [["+yg$]], "yank till end of line into clipboard" },
    ["<leader>p"] = { [["+p]], "paste from clipboard", { "n", "v" } },
    ["J"] = { "mzJ`z", "better join" },
    ["<m-j>"] = {
      n = { ":m .+1<cr>==", "move line down" },
      v = { ":m '>+1<cr>gv=gv", "move block down" },
    },
    ["<m-k>"] = {
      n = { ":m .-2<cr>==", "move line down" },
      v = { ":m '<-2<cr>gv=gv", "move block down" },
    },
    ["<"] = { "<gv", "de-indent", "v" },
    [">"] = { ">gv", "indent", "v" },
    ["<c-h>"] = { "<c-w>h", "move to split left" },
    ["<c-j>"] = { "<c-w>j", "move to split down" },
    ["<c-k>"] = { "<c-w>k", "move to split up" },
    ["<c-l>"] = { "<c-w>l", "move to split right" },
    ["<m-H>"] = { "<cmd>vertical resize -2<cr>", "decrease width" },
    ["<m-J>"] = { "<cmd>resize +2<cr>", "increase height" },
    ["<m-K>"] = { "<cmd>resize -2<cr>", "decrease height" },
    ["<m-L>"] = { "<cmd>vertical resize +2<cr>", "increase width" },
    ["<c-s><c-s>"] = { ":split<cr>", "horizontal split" },
    ["<c-s><c-v>"] = { ":vsplit<cr>", "vertical split" },
    ["<F8>"] = { ":cnext<cr>", "cnext" },
    ["<F7>"] = { ":cprev<cr>", "cprev" },
    ["<F6>"] = { ":cclose<cr>", "cprev" },
    ["<F4>"] = {
      function()
        vim.diagnostic.jump({ count = 1 })
      end,
      "next diag",
    },
    ["<F3>"] = {
      function()
        vim.diagnostic.jump({ count = -1 })
      end,
      "prev diag",
    },

    ["<leader>fp"] = { ":Explore<cr>", "netrw" },
    ["<leader>ff"] = { file_search, "file search" },
    ["<leader>sx"] = { scratch_to_quickfix, "dump buffer content to quickfix" },

    ["<leader>gd"] = {
      function()
        extcmd_to_scratch({ "git", "diff" }, false)
      end,
      "send git diff to scratch",
    },
    ["<leader>gb"] = {
      function()
        extcmd_to_scratch({ "git", "blame", vim.fn.expand("%") }, false)
      end,
      "send git blame to scratch",
    },
    ["<leader>sf"] = {
      function()
        vim.ui.input({ prompt = "> " }, function(pat)
          if pat then
            vim.cmd("Tgrep " .. pat)
          end
        end)
      end,
      "grep pattern and send to qf",
    },
    ["<leader>ss"] = {
      function()
        vim.ui.input({ prompt = "> " }, function(pat)
          if pat then
            vim.cmd("Tgrep! " .. pat)
          end
        end)
      end,
      "grep pattern and send to scratch",
    },

    ["<leader>;f"] = { ":Tform %<cr>", "run formatter" },
    ["<leader>;t"] = { ":Ttest<cr>", "run tests" },
    ["<leader>;c"] = { ":Tcheck<cr>", "run lints" },
    ["<leader>;m"] = { ":make<cr>", "run make" },

    ["<leader>mp"] = { "mP", "mark P" },
    ["<leader>mf"] = { "mF", "mark F" },
    ["<leader>mw"] = { "mW", "mark W" },
    ["<leader>mq"] = { "mQ", "mark Q" },
    ["<leader>mb"] = { "mB", "mark B" },
    ["<m-p>"] = { "`P", "goto mark P" },
    ["<m-f>"] = { "`F", "goto mark F" },
    ["<m-w>"] = { "`W", "goto mark W" },
    ["<m-q>"] = { "`Q", "goto mark Q" },
    ["<m-b>"] = { "`B", "goto mark B" },

    ["<c-i>"] = {
      function()
        return pumvisible() and "<c-e>" or "<c-i>"
      end,
      { expr = true, desc = "cancel completion" },
      "i",
    },
    ["<c-n>"] = {
      function()
        if pumvisible() then
          feedkeys("<c-n>")
        elseif vim.bo.omnifunc == "" then
          feedkeys("<c-x><c-n>")
        else
          feedkeys("<c-x><c-o>")
        end
      end,
      "trigger/next completion",
      "i",
    },
    ["<c-e>"] = {
      function()
        if pumvisible() then
          feedkeys("<c-p>")
        elseif vim.bo.omnifunc == "" then
          feedkeys("<c-x><c-p>")
        else
          feedkeys("<c-x><c-o>")
        end
      end,
      "trigger/prev completion",
      "i",
    },
    ["<C-u>"] = { "<C-x><C-n>", { desc = "Buffer completions" }, "i" },
    ["<C-f>"] = { "<C-x><C-f>", { desc = "Path completions" }, "i" },
    ["grc"] = { vim.diagnostic.setqflist, "setqflist" },
    ["grC"] = { vim.diagnostic.setloclist, "setloclist" },
    ["gd"] = { vim.lsp.buf.definition, "goto definition" },
    ["gD"] = { vim.lsp.buf.declaration, "goto declaration" },
    ["gwd"] = { ":vsplit | lua vim.lsp.buf.definition()<cr>", "goto definition in vsplit" },
    ["gwD"] = { ":vsplit | lua vim.lsp.buf.declaration()<cr>", "goto declaration in vsplit" },
    ["grt"] = { vim.lsp.buf.type_definition, "goto typedef" },
    ["gri"] = { vim.lsp.buf.implementation, "goto impl" },
    ["gO"] = { vim.lsp.buf.document_symbol, "document symbols" },
    ["gh"] = { vim.diagnostic.open_float, "open float" },
    ["<c-s>"] = { vim.lsp.buf.signature_help, "signature help", "i" },
    ["<Tab>"] = {
      function()
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
      end,
      "next snippet position",
      { "i", "s" },
    },
    ["<S-Tab>"] = {
      function()
        if vim.snippet.active({ direction = -1 }) then
          vim.snippet.jump(-1)
        else
          feedkeys("<S-Tab>")
        end
      end,
      "previous snippet position",
      { "i", "s" },
    },
    ["<BS>"] = { "<C-o>s", "remove snippet placeholder", "s" },
  })
  :each(create_keymap)

-- >>> FT {{{2
vim
  .iter({
    ["c|cpp"] = { format = "clang-format -i" },
    ["go"] = {
      misc = function()
        vim.bo.expandtab = false
      end,
    },
    ["python"] = {
      format = function()
        return "poetry --project " .. find_root(roots.python) .. " run black"
      end,
    },
    ["rust"] = {
      format = "cargo fmt",
      check = function()
        return {
          cmd = { "cargo", "check" },
          cwd = find_root(roots.rust),
        }
      end,
      -- test = function()
      --   return {
      --     cmd = { "cargo", "test" },
      --     cwd = find_root(roots.rust)
      --   }
      -- end,
      -- make = function()
      --   return {
      --     cmd = { "cargo", "build" },
      --     cwd = find_root(roots.rust)
      --   }
      -- end,
    },
    ["zig"] = { format = "zig fmt" },

    ["bash|sh"] = { format = "shellharden" },

    ["lua"] = { format = "stylua" },
    ["nix"] = { format = "nixpkgs-fmt" },

    ["javascript|javascriptreact|typescript|typescriptreact"] = {
      format = "prettier -w",
    },
    ["html|astro"] = {
      format = "prettier -w",
    },
    ["css|scss"] = {
      format = "prettier -w",
    },
    ["json|jsonc"] = {
      format = "prettier -w",
    },
    ["markdown"] = {
      format = "prettier -w",
      misc = function()
        create_keymap("<cr>", {
          function()
            local ts_utils = require("nvim-treesitter.ts_utils")
            local node = ts_utils.get_node_at_cursor()
            if node and node:type() == "link_destination" then
              local start_row, start_col, end_row, end_col = node:range(false)
              local dest = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
              if dest[1] then
                local re = vim.regex([[^\(https\=:\/\/\|www.\)]])
                local x, _ = re:match_str(dest[1])
                if x ~= nil then
                  vim.system({ vim.g.open_cmd, dest[1] })
                else
                  vim.cmd("e " .. dest[1])
                end
              end
            end
          end,
          { desc = "in markdown, open link destination", buffer = vim.api.nvim_get_current_buf() },
        })
      end,
    },

    ["man|help"] = {
      misc = function()
        create_keymap("q", { ":q<cr>", { desc = "quit", buffer = vim.api.nvim_get_current_buf() } })
      end,
    },

    ["gitcommit"] = {
      misc = function()
        vim.bo.textwidth = 72
        vim.wo.colorcolumn = "+0"
        vim.wo.spell = true
        create_keymap(
          "<c-c>",
          { ":wq<cr>", { desc = "write commit", buffer = vim.api.nvim_get_current_buf() }, { "n", "i" } }
        )
      end,
    },
  })
  :each(create_ft_aucmd)

-- >>> USERCMDS {{2
vim
  .iter({
    {
      "Tup",
      function(opts)
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
      end,
      {
        nargs = "*",
        desc = "update packages",
      },
    },
    {
      "Tgrep",
      function(opts)
        local cmd = {}
        if is_git_repo() then
          cmd = { "git", "grep", "-nE" }
        else
          cmd = { "rg", "--vimgrep", "--no-column", "-ne" }
        end
        vim.list_extend(cmd, { opts.args })
        extcmd_to_scratch(cmd, not opts.bang)
      end,
      {
        nargs = "+",
        desc = "format file",
        bang = true,
      },
    },
  })
  :each(create_command)

-- >>> AUTOCOMMANDS {{{2
local user_group = vim.api.nvim_create_augroup("UserConfig", {})
vim
  .iter({
    {
      event = "TextYankPost",
      group = user_group,
      callback = function()
        vim.highlight.on_yank()
      end,
    },
    {
      event = "BufReadPost",
      group = user_group,
      callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
          pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
      end,
    },
    {
      event = "BufWritePre",
      group = user_group,
      callback = function()
        local dir = vim.fn.expand("<afile>:p:h")
        mkdirp(dir)
      end,
    },
    {
      event = { "BufEnter", "BufNewFile", "BufRead" },
      pattern = "*.mdx",
      callback = function()
        vim.bo.filetype = "markdown"
      end,
    },
    {
      event = "BufEnter",
      group = vim.api.nvim_create_augroup("Git", {}),
      pattern = "COMMIT_EDITMSG",
      callback = function()
        vim.wo.spell = true
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
        if vim.fn.getline(1) == "" then
          vim.cmd("startinsert!")
        end
      end,
    },
    {
      event = "BufEnter",
      group = user_group,
      pattern = "*nvim/init.lua",
      callback = function()
        vim.o.foldmethod = "marker"
        vim.o.foldlevel = 2
      end,
    },
    {
      event = "LspAttach",
      callback = function(ev)
        -- most of this was lifted from this gist:
        -- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc#file-builtin-compl-lua
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

        if client and client:supports_method("textDocument/completion") then
          vim.lsp.completion.enable(true, ev.data.client_id, ev.buf, {
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
      end,
    },
  })
  :each(create_aucmd)

-- >>> LSP {{2
vim
  .iter({
    pyright = {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = roots.python,
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

        vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", function(path)
          local clients = vim.lsp.get_clients({
            bufnr = vim.api.nvim_get_current_buf(),
            name = "pyright",
          })
          for _, c in ipairs(clients) do
            if c.settings then
              c.settings.python = vim.tbl_deep_extend("force", c.settings.python, { pythonPath = path })
            else
              c.config.settings = vim.tbl_deep_extend("force", c.config.settings, { python = { pythonPath = path } })
            end
            c.notify("workspace/didChangeConfiguration", { settings = nil })
          end
        end, {
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
    },

    lua_ls = {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      root_markers = { ".git" },
      settings = { Lua = { workspace = { library = vim.api.nvim_get_runtime_file("", true) } } },
    },

    rust_analyzer = {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_markers = roots.rust,
    },
  })
  :each(create_lsp_config)

-- >>> COLORS {{{3
local function cs_gruvsimple()
  if vim.g.highlights_loaded then
    return
  end

  vim.cmd("hi clear")

  local black = "#32302f"
  local red = "#ea6962"
  local green = "#a9b665"
  local yellow = "#d8a657"
  local blue = "#7daea3"
  local magenta = "#d3869b"
  local cyan = "#89b482"
  local white = "#ddc7a1"

  local fg_0 = "#d4be98"
  local fg_1 = "#d4be98"
  local bg_0 = "#1d2021"
  local bg_1 = black
  local bg_2 = "#5a524c"
  local bg_3 = "#7c6f64"
  local window_bg = nil
  local accent = "#e78a4e"

  if vim.o.background == "light" then
    black = "#654735"
    red = "#c14a4a"
    green = "#6c782e"
    yellow = "#b47109"
    blue = "#45707a"
    magenta = "#945f80"
    cyan = "#4c7a5d"
    white = "#a89984"

    bg_0 = "#f2e5bc"
    bg_1 = "#e6d5ae"
    bg_2 = "#d5c4a1"
    bg_3 = "#7c6f64"
    fg_0 = "#654735"
    fg_1 = "#4f3829"
    window_bg = bg_0
    accent = "#c35e0a"
  end

  vim.g.terminal_color_0 = black
  vim.g.terminal_color_1 = red
  vim.g.terminal_color_2 = green
  vim.g.terminal_color_3 = yellow
  vim.g.terminal_color_4 = blue
  vim.g.terminal_color_5 = magenta
  vim.g.terminal_color_6 = cyan
  vim.g.terminal_color_7 = white
  vim.g.terminal_color_8 = black
  vim.g.terminal_color_9 = red
  vim.g.terminal_color_10 = green
  vim.g.terminal_color_11 = yellow
  vim.g.terminal_color_12 = blue
  vim.g.terminal_color_13 = magenta
  vim.g.terminal_color_14 = cyan
  vim.g.terminal_color_15 = white

  vim
    .iter({
      -- UI
      Added = { fg = green },
      Changed = { fg = blue },
      ColorColumn = { bg = bg_1 },
      Conceal = {},
      CurSearch = { link = "Search" },
      Cursor = { bg = bg_1 },
      CursorLine = { bg = bg_1 },
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
      DiffFile = { fg = fg_0, bold = true },
      Directory = { fg = blue },
      EndOfBuffer = { fg = bg_3, bg = window_bg },
      Error = { link = "ErrorMsg" },
      ErrorMsg = { fg = red, bold = true },
      FloatBorder = { fg = fg_1, bg = bg_1 },
      FoldColumn = { link = "SignColumn" },
      Folded = { link = "Comment" },
      Hint = { link = "HintMsg" },
      HintMsg = { fg = blue, bold = true },
      IncSearch = { link = "Search" },
      Info = { link = "ErrorMsg" },
      InfoMsg = { fg = cyan, bold = true },
      LineNr = { bold = true },
      LineNrAbove = { fg = bg_3, bold = false },
      LineNrBelow = { link = "LineNrAbove" },
      MatchParen = { bg = bg_2, bold = true },
      ModeMsg = { link = "Normal", bold = true },
      MoreMsg = { link = "Normal", bold = true },
      Normal = { fg = fg_0, bg = window_bg },
      NormalFloat = { fg = fg_1, bg = bg_1 },
      Pmenu = { bg = bg_1, fg = fg_1 },
      PmenuKind = { fg = blue },
      PmenuKindSel = { bg = bg_2, fg = blue, bold = true },
      PmenuSbar = { bg = bg_1, fg = fg_1 },
      PmenuSel = { bg = bg_2, fg = white, bold = true },
      PmenuThumb = { bg = bg_1, fg = fg_1 },
      Question = { fg = yellow, bold = true },
      QuickFixLine = { fg = yellow },
      Removed = { fg = green },
      Search = { bg = yellow, fg = bg_0 },
      SignColumn = { fg = bg_3, bg = bg_0 },
      SpecialKey = { fg = blue },
      Title = { link = "NormalFloat" },
      Todo = { fg = accent },
      Visual = { bg = bg_2 },
      Warning = { link = "WarningMsg" },
      WarningMsg = { fg = yellow, bold = true },
      WildMenu = { link = "Pmenu" },

      -- statusline
      LinePrimaryBlock = { fg = bg_1, bg = bg_0 },
      LineSecondaryBlock = { fg = blue, bg = bg_0 },
      LineError = { link = "Error" },
      LineHint = { link = "Hint" },
      LineInfo = { link = "Info" },
      LineWarning = { link = "Warning" },
      StatusLine = { fg = fg_1, bg = bg_1, bold = true },
      StatusLineNC = { fg = bg_3, bg = bg_0 },
      StatusLineTab = { link = "StatusLine" },

      -- Syntax
      Boolean = { link = "Constant" },
      Character = { link = "String" },
      Comment = { fg = bg_3, italic = true },
      Constant = { fg = yellow },
      Delimiter = { link = "Normal" },
      Function = { fg = cyan },
      Identifier = { fg = fg_0 },
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
      ["@markup.raw.markdown_inline"] = { bg = bg_1, fg = fg_0, italic = true},

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
    })
    :each(set_hl)

  vim.g.highlights_loaded = true
end

cs_gruvsimple()
