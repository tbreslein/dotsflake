vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- >>> PREAMBLE
vim.g.uname = vim.uv.os_uname().sysname
local notif_ring_buffer = vim.ringbuf(36)

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
      -- matches filename:line:col:text
      local filename, lnum, _, text = line:match("^([^:]+):(%d+):(%d+):(.*)$")
      if filename and lnum then
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

local function extcmd_to_scratch(extcmd, opts)
  local function on_exit(out)
    local output = ""

    if opts.use_stdout ~= nil or opts.use_stderr ~= nil then
      if opts.use_stdout and opts.use_stderr then
        output = "STDOUT:\n\n" .. out.stdout .. "\n\nSTDERR:\n\n" .. out.stderr
      elseif opts.use_stdout then
        output = out.stdout
      elseif opts.use_stderr then
        output = out.stderr
      else
        local cmd_str = vim.iter(extcmd):join(" ")
        vim.notify_once("command exited without output: " .. cmd_str, vim.log.levels.WARN)
        return
      end
    else
      if #out.stderr > 0 then
        output = out.stderr
      elseif #out.stdout > 0 then
        output = out.stdout
      else
        local cmd_str = vim.iter(extcmd):join(" ")
        vim.notify_once("command exited without output: " .. cmd_str, vim.log.levels.WARN)
        return
      end
    end

    vim.cmd("vnew")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n", { trimempty = true }))
    vim.bo.buftype = "nofile"
    vim.bo.bufhidden = "wipe"
    vim.bo.swapfile = false

    if opts.quickfix then
      scratch_to_quickfix()
    end
  end

  -- NOTE: the schedule_wrap ensures that the wrapped function executes back on
  -- the main thread. vim.system runs async, and in that context you cannot run
  -- things like vim.cmd and vim.api.*, because those assume that they are
  -- calleed on the main thread
  vim.system(extcmd, { cwd = opts.cwd, text = true }, vim.schedule_wrap(on_exit))
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

local function pumvisible()
  return tonumber(vim.fn.pumvisible()) ~= 0
end

local function feedkeys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
end

local function find_root(additional_markers)
  local markers = {}
  if additional_markers ~= nil then
    markers = { additional_markers, ".git/" }
  else
    markers = { ".git/" }
  end

  local r = vim.fs.root(0, markers)
  if r == nil then
    r = vim.fn.expand("%:p")
  end
  return r
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
  extcmd_in_floatterm(extcmd .. " | fzf --height=12 --reverse --style=minimal --color=bw", function(stdout)
    local selected, _ = stdout:gsub("\n", "")
    if #selected > 0 then
      vim.cmd("bd!")
      vim.cmd("e " .. selected)
    end
  end)
end

-- >>> SETTINGS
-- >>> PACK
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

-- >>> OPTS
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

vim.g.netrw_banner = 0
-- vim.g.netrw_browse_split = 4
-- vim.g.netrw_altv = 1
vim.g.netrw_liststyle = 3

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
    lua = { ".luacheckrc" },
    nix = { "flake.nix" },
    rust = { "Cargo.toml" },
    javascript = { "package.json" },
    zig = { "build.zig" },
  })
  :fold({}, function(acc, k, v)
    acc[k] = vim.list_extend(v, { ".git" })
    return acc
  end)

-- >>> COMPLETION
vim.opt.completeopt = { "fuzzy", "menu", "menuone", "noselect", "noinsert", "popup", "preview" }
vim.opt.pumheight = 20
vim.opt.pumwidth = 45

vim.g.grepprg = "ag --hidden --vimgrep"
vim.g.grepformat = "%f:%l:%c:%m"
vim.diagnostic.config({ virtual_text = { current_line = true } })

-- >>> KEYMAPS
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
    ["<m-j>"] = { ":m '>+1<cr>gv=gv", "move block down" },
    ["<m-k>"] = { ":m '<-2<cr>gv=gv", "move block down" },
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
    ["<leader>X"] = { scratch_to_quickfix, "dump buffer content to quickfix" },

    ["<leader>gd"] = {
      function()
        extcmd_to_scratch({ "git", "diff" }, { quickfix = false })
      end,
      "send git diff to scratch",
    },
    ["<leader>gb"] = {
      function()
        extcmd_to_scratch({ "git", "blame", vim.fn.expand("%") }, { quickfix = false })
      end,
      "send git blame to scratch",
    },

    ["<leader>sr"] = {
      function()
        vim.ui.input({ prompt = "> " }, function(pat)
          if pat then
            vim.cmd("Tgrep " .. pat)
          end
        end)
      end,
      "Search Recursively",
    },
    ["<leader>ss"] = {
      function()
        vim.ui.input({ prompt = "> " }, function(pat)
          if pat then
            vim.cmd("Tgrep! " .. pat)
          end
        end)
      end,
      "Search into Scratch",
    },
    ["<leader>sf"] = {
      function()
        vim.ui.input({ prompt = "> " }, function(pat)
          if pat then
            vim.cmd("Fgrep " .. pat)
          end
        end)
      end,
      "Search across fil",
    },

    ["<leader>;f"] = { ":Format<cr>", "run formatter" },
    ["<leader>;t"] = { ":Test<cr>", "run tests" },
    ["<leader>;c"] = { ":Lint<cr>", "run lints" },
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
    ["<C-l>"] = { "<C-x><C-n>", { desc = "Buffer completions" }, "i" },
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
    ["<leader>N"] = {
      function()
        local lines = {}
        for l in notif_ring_buffer do
          lines = vim.list_extend(lines, { l })
        end

        -- NOTE: iterating over a ring buffer clears it, so we need to
        -- repopulate it now
        for _, l in ipairs(lines) do
          notif_ring_buffer:push(l)
        end

        vim.cmd("vnew")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
      end,
      "print notification ring buffer",
    },
  })
  :each(create_keymap)

-- >>> FT
local my_ft_settings = {}
vim
  .iter({
    ["c|cpp"] = { format = { "clang-format", "-i" } },
    ["go"] = {
      misc = function()
        vim.bo.expandtab = false
      end,
    },
    ["python"] = {
      format = function()
        return {
          cmd = { "poetry", "--project", find_root(roots.python), "run", "black" },
        }
      end,
    },
    ["rust"] = {
      format = { cmd = { "cargo", "fmt" }, project_wide = true },
      lint = { "cargo", "check" },
      test = { "cargo", "test" },
      build = { "cargo", "build" },
    },
    ["zig"] = { format = { "zig", "fmt" } },

    ["bash|sh"] = { format = { "shellharden" } },

    ["lua"] = {
      format = { "stylua" },
      lint = {
        cmd = { "luacheck", "--formatter", "plain", "." },
        quickfix = false,
      },
    },
    ["nix"] = { format = { "nixpkgs-fmt" } },

    ["javascript|javascriptreact|typescript|typescriptreact"] = {
      format = { "prettier", "-w" },
    },
    ["html|astro"] = {
      format = { "prettier", "-w" },
    },
    ["css|scss"] = {
      format = { "prettier", "-w" },
    },
    ["json|jsonc"] = {
      format = { "prettier", "-w" },
    },
    ["markdown"] = {
      format = { "prettier", "-w" },
      misc = function()
        vim.wo.spell = true
        vim.wo.linebreak = true
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
                  vim.cmd("Open " .. dest[1])
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
      end,
    },
  })
  :each(function(k, v)
    local patterns = vim.split(k, "|", { trimempty = true })
    if v.misc ~= nil then
      vim.api.nvim_create_autocmd("FileType", {
        pattern = patterns,
        callback = v.misc,
      })
    end

    for _, pat in ipairs(patterns) do
      my_ft_settings[pat] = {
        format = v.format,
        lint = v.lint,
        test = v.test,
        build = v.build,
      }
    end
  end)

vim.api.nvim_create_user_command("Format", function()
  local format = my_ft_settings[vim.bo.filetype].format
  if format ~= nil then
    local cmd_table = {}

    if type(format) == "function" then
      cmd_table = format()
    elseif vim.islist(format) then
      cmd_table = { cmd = vim.fn.deepcopy(format) }
    else
      cmd_table = vim.fn.deepcopy(format)
    end

    if not cmd_table.project_wide then
      cmd_table.cmd = vim.list_extend(cmd_table.cmd, { vim.fn.expand("%:p") })
    end

    if cmd_table.cwd == nil then
      cmd_table.cwd = find_root(roots[vim.bo.filetype])
    else
      cmd_table.cwd = find_root(cmd_table.cwd)
    end

    local out = vim.system(cmd_table.cmd, { cwd = cmd_table.cwd }):wait()
    if out.stdout ~= nil and out.stderr ~= nil and out.stdout == out.stderr then
      vim.notify(out.stdout, vim.log.levels.INFO)
    elseif out.stdout ~= nil and #vim.trim(out.stdout) > 0 then
      vim.notify(out.stdout, vim.log.levels.INFO)
    elseif out.stderr ~= nil and #vim.trim(out.stderr) > 0 then
      vim.notify(out.stderr, vim.log.levels.ERROR)
    end
    vim.cmd("e")
  end
end, { desc = "run formatter" })

-- TODO: the contents of the Lint and Test user command are almost identical
vim.api.nvim_create_user_command("Lint", function()
  local lint = my_ft_settings[vim.bo.filetype].lint
  if lint ~= nil then
    local lint_table = {}

    if type(lint) == "function" then
      lint_table = lint()
    elseif vim.islist(lint) then
      lint_table = { cmd = vim.fn.deepcopy(lint) }
    else
      lint_table = vim.fn.deepcopy(lint)
    end

    local cwd = ""
    if lint_table.cwd == nil then
      if roots[vim.bo.filetype] == nil then
        cwd = vim.fn.expand("%:p:h")
      else
        cwd = find_root(roots[vim.bo.filetype])
      end
    else
      cwd = find_root(lint_table.cwd)
    end

    vim.notify("Async running command:\n" .. vim.iter(lint_table.cmd):join(" "), vim.log.levels.INFO)
    extcmd_to_scratch(lint_table.cmd, { quickfix = lint_table.quickfix, cwd = cwd })
  end
end, { desc = "run linter" })

vim.api.nvim_create_user_command("Test", function()
  local test = my_ft_settings[vim.bo.filetype].test
  if test ~= nil then
    local test_table = {}

    if type(test) == "function" then
      test_table = test()
    elseif vim.islist(test) then
      test_table = { cmd = vim.fn.deepcopy(test) }
    else
      test_table = vim.fn.deepcopy(test)
    end

    local cwd = ""
    if test_table.cwd == nil then
      if roots[vim.bo.filetype] == nil then
        cwd = vim.fn.expand("%:p:h")
      else
        cwd = find_root(roots[vim.bo.filetype])
      end
    else
      cwd = find_root(test_table.cwd)
    end
    extcmd_to_scratch(test_table.cmd, { quickfix = test_table.quickfix, cwd = cwd, use_stdout = true })
  end
end, { desc = "run linter" })

-- >>> USERCMDS
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
        extcmd_to_scratch({ "ag", "--hidden", "--vimgrep", opts.args }, { quickfix = not opts.bang })
      end,
      {
        nargs = 1,
        desc = "grep across project",
        bang = true,
      },
    },
    {
      "Fgrep",
      function(opts)
        extcmd_to_scratch({ "ag", opts.fargs[1], vim.fn.expand("%") }, { quickfix = not opts.bang })
      end,
      {
        nargs = 1,
        desc = "grep in current file",
        bang = true,
      },
    },
  })
  :each(function(c)
    vim.api.nvim_create_user_command(c[1], c[2], c[3])
  end)

-- >>> AUTOCOMMANDS
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
      event = "LspAttach",
      callback = function(ev)
        -- most of this was lifted from this gist:
        -- https://gist.github.com/MariaSolOs/2e44a86f569323c478e5a078d0cf98cc#file-builtin-compl-lua
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client ~= nil then
          vim.notify("Lsp attached:\n" .. client.name, vim.log.levels.INFO)
        end

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
  :each(function(au)
    vim.api.nvim_create_autocmd(au.event, {
      pattern = au.pattern,
      group = au.group,
      callback = au.callback,
    })
  end)

-- >>> LSP
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
  :each(function(ls_server, ls_config)
    vim.lsp.enable(ls_server)
    vim.lsp.config(ls_server, ls_config)
  end)

-- >>> COLORS
local notif_namespace = vim.api.nvim_create_namespace("notifications")

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
      ["@markup.raw.markdown_inline"] = { bg = bg_1, fg = fg_0, italic = true },

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

      NotifyBorder = { fg = accent, bg = bg_0 },
      NotifyText = { fg = fg_0, bg = bg_0 },
    })
    :each(function(hl_group, hl_config)
      vim.api.nvim_set_hl(0, hl_group, hl_config)
      vim.api.nvim_set_hl(notif_namespace, hl_group, hl_config)
    end)

  vim
    .iter({
      FloatBorder = { link = "NotifyBorder" },
      NormalFloat = { link = "NotifyText" },
    })
    :each(function(hl_group, hl_config)
      vim.api.nvim_set_hl(notif_namespace, hl_group, hl_config)
    end)

  vim.g.highlights_loaded = true
end

cs_gruvsimple()

local current_notif_height = 0
local function notify(msg, level, _)
  local max_width = 36
  local max_height = 6

  local lines = vim.split(msg, "\n")
  if #lines == 0 then
    return
  end

  local title = nil

  if level == vim.log.levels.DEBUG then
    title = "Debug"
  elseif level == vim.log.levels.ERROR then
    title = "Error"
  elseif level == vim.log.levels.INFO then
    title = "Info"
  elseif level == vim.log.levels.TRACE then
    title = "Trace"
  elseif level == vim.log.levels.WARN then
    title = "Warn"
  end

  notif_ring_buffer:push("[" .. vim.fn.strftime("%Y-%m-%d %T") .. "|" .. title .. "] " .. msg)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })

  local height = math.min(#lines, max_height)
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(#l, width)
  end
  width = math.min(width, max_width)
  width = math.max(width, #title + 1)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "laststatus",
    style = "minimal",
    title = title,
    focusable = false,
    zindex = 100,
    noautocmd = true,
    width = width,
    height = height,
    anchor = "SE",
    col = vim.o.columns,
    row = -current_notif_height,
  })

  vim.api.nvim_win_set_hl_ns(win, notif_namespace)

  local full_height = height + 3
  current_notif_height = current_notif_height + full_height

  vim.system(
    { "sleep", "5" },
    {},
    vim.schedule_wrap(function()
      vim.cmd("bd! " .. buf)
      current_notif_height = current_notif_height - full_height
    end)
  )
end
vim.notify = notify
