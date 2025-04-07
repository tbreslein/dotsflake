local function map(mode, keys, action, opts, desc)
	vim.keymap.set(
		mode,
		keys,
		action,
		vim.tbl_extend("keep", opts or {}, { noremap = true, silent = true, desc = desc })
	)
end

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
		map("n", "q", "<cmd>close<cr>", { buffer = event.buf })
	end,
})

map("n", "Q", "<nop>")
map("n", "<esc>", ":noh<cr>")
map("v", "P", [["_dP]])
map({ "n", "x", "v" }, "x", [["_x]])
map("n", "Y", "yg$")
map("n", "J", "mzJ`z")
map("n", "n", "nzz")
map("n", "N", "Nzz")
map("n", "*", "*zz")
map("n", "#", "#zz")
map("n", "g*", "g*zz")
map("n", "g#", "g#zz")
map("n", "<c-d>", "<c-d>zz")
map("n", "<c-u>", "<c-u>zz")
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("n", "]c", ":cnext<cr>")
map("n", "[c", ":cprev<cr>")

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

-- UI / EDITING
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

package.preload["nvim-web-devicons"] = function()
	package.loaded["nvim-web-devicons"] = {}
	require("mini.icons").mock_nvim_web_devicons()
	return package.loaded["nvim-web-devicons"]
end

require("nvim-treesitter.configs").setup({
	-- ensure_installed = {
	--   "lua",
	--   "vimdoc",
	--   "rust",
	--   "zig",
	--   "c",
	--   "cpp",
	--   "python",
	--   "go",
	--   "haskell",
	--   "astro",
	--   "javascript",
	--   "typescript",
	--   "toml",
	--   "yaml",
	--   "markdown",
	--   "markdown_inline",
	-- },
	textobjects = {
		swap = {
			enable = true,
			swap_next = {
				["<leader>sa"] = "@parameter.inner",
			},
			swap_previous = {
				["<leader>SA"] = "@parameter.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]m"] = "@function.outer",
				["]/"] = "@comment.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[/"] = "@comment.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
			},
		},
		select = {
			enable = true,
			lookahead = true,
			keymaps = {
				["am"] = "@function.outer",
				["im"] = "@function.inner",
				["a/"] = "@comment.outer",
				["i/"] = "@comment.inner",
				["ac"] = "@class.outer",
				["ic"] = "@class.inner",
				["aa"] = "@parameter.inner",
				["ia"] = "@parameter.inner",
			},
			selection_modes = {
				["@parameter.outer"] = "v", -- charwise
				["@function.outer"] = "V", -- linewise
				["@class.outer"] = "<c-v>", -- blockwise
			},
		},
	},
	highlight = { enable = true, use_languagetree = true },
	indent = { enable = true },
})
require("treesitter-context").setup({ multiline_threshold = 2 })
vim.cmd([[hi TreesitterContextBottom gui=underline]])

require("render-markdown").setup({
	-- latex = { enabled = false },
	completions = { lsp = { enabled = true }, blink = { enabled = true } },
})

local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
		hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
		todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
		note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
		perf = { pattern = "%f[%w]()PERF()%f[%W]", group = "MiniHipatternsNote" },
		warn = { pattern = "%f[%w]()WARN()%f[%W]", group = "MiniHipatternsFixme" },
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})
require("mini.trailspace").setup()
require("mini.indentscope").setup()

map("n", "<leader>gg", "<cmd>Neogit<cr>")
local lsp_progress = require("lsp-progress")
lsp_progress.setup({
	-- max_size = 20,
	client_format = function(client_name, spinner, series_messages)
		return #series_messages > 0 and ("[" .. client_name .. "] " .. spinner) or nil
	end,
	format = function(client_messages)
		-- icon: nf-fa-gear \uf013
		local sign = " "
		if #client_messages > 0 then
			return sign .. " " .. table.concat(client_messages, " ")
		end
		if #require("lsp-progress.api").lsp_clients() > 0 then
			return sign
		end
		return ""
	end,
})

Statusline = {}
local filepath = function()
	local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
	if fpath == "" or fpath == "." then
		return " "
	end
	return string.format(" %%<%s", fpath) .. "%m | "
end

local lsp = function()
	local count = {}

	count["errors"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
	count["warnings"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
	count["hints"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
	count["info"] = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

	local err_string = ""

	if count["errors"] ~= 0 then
		err_string = err_string .. " %#LspDiagnosticsSignError#" .. vim.g.diag_symbol_error .. " " .. count["errors"]
	end
	if count["warnings"] ~= 0 then
		err_string = err_string .. " %#LspDiagnosticsSignWarning#" .. vim.g.diag_symbol_warn .. " " .. count["warnings"]
	end
	if count["hints"] ~= 0 then
		err_string = err_string .. " %#LspDiagnosticsSignHint#" .. vim.g.diag_symbol_hint .. " " .. count["hints"]
	end
	if count["info"] ~= 0 then
		err_string = err_string .. " %#LspDiagnosticsSignInformation#" .. vim.g.diag_symbol_info .. " " .. count["info"]
	end

	if #err_string > 0 then
		err_string = err_string .. "%#Normal#" .. " | "
	end
	return err_string .. lsp_progress.progress()
end

Statusline.active = function()
	return table.concat({
		filepath(),
		lsp(),
		"%=%P | %l:%c ",
	})
end

vim.api.nvim_exec2(
	[[
    augroup Statusline
    au!
    au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
    augroup END
  ]],
	{}
)

vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
	group = "lualine_augroup",
	pattern = "LspProgressStatusUpdated",
	callback = function()
		vim.cmd("redrawstatus")
	end,
})

-- TOOLS
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

-- NAVIGATION
local fzflua = require("fzf-lua")
fzflua.setup({
	winopts = {
		border = vim.g.borderstyle,
		preview = { layout = "vertical" },
	},
	fzf_opts = { ["--layout"] = false },
})
map("n", "<leader>ff", fzflua.files)
map("n", "<leader>fs", fzflua.live_grep)

require("mini.move").setup({
	mappings = {
		left = "<M-h>",
		right = "<M-l>",
		down = "<M-j>",
		up = "<M-k>",

		line_left = nil,
		line_right = nil,
		line_down = nil,
		line_up = nil,
	},
})

local mini_files = require("mini.files")
mini_files.setup()
map("n", "<leader>fp", function()
	mini_files.open(vim.api.nvim_buf_get_name(0))
end)

require("tmux").setup()

require("grapple").setup()
map("n", "<leader>a", "<cmd>Grapple tag<cr>")
map("n", "<leader>e", "<cmd>Grapple toggle_tags<cr>")
map("n", "<A-r>", "<cmd>Grapple select index=1<cr>")
map("n", "<A-e>", "<cmd>Grapple select index=2<cr>")
map("n", "<A-w>", "<cmd>Grapple select index=3<cr>")
map("n", "<A-q>", "<cmd>Grapple select index=4<cr>")

require("grug-far").setup()

-- LSP
vim.g.rustaceanvim = { server = { default_settings = { ["rust-analyzer"] = { check = { command = "check" } } } } }

local lspconfig = require("lspconfig")
local blink = require("blink.cmp")

blink.setup({
	keymap = {
		preset = "default",
		["<c-j>"] = { "select_next" },
		["<c-k>"] = { "select_prev" },
		["<c-l>"] = { "accept" },
		["<c-n>"] = { "scroll_documentation_up" },
		["<c-f>"] = { "scroll_documentation_down" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
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
		per_filetype = {
			org = { "orgmode" },
		},
		providers = {
			orgmode = {
				name = "Orgmode",
				module = "orgmode.org.autocompletion.blink",
				fallbacks = { "buffer" },
			},
		},
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
-- lspconfig.ruff.setup({ capabilities = lsp_capabilities })
lspconfig.ts_ls.setup({ capabilities = lsp_capabilities })
lspconfig.zls.setup({ capabilities = lsp_capabilities })

lspconfig.pyright.setup({
	capabilities = lsp_capabilities,
	on_new_config = function(config, root_dir)
		local env =
			vim.trim(vim.fn.system('cd "' .. (root_dir or ".") .. '"; poetry env info --executable 2>/dev/null'))
		if string.len(env) > 0 then
			config.settings.python.pythonPath = env
		end
	end,
})

require("tiny-inline-diagnostic").setup({
	preset = "minimal",
})
vim.diagnostic.config({
	virtual_text = false,
	underline = { severity = { min = vim.diagnostic.severity.WARN } },
	signs = {
		text = {
			[vim.diagnostic.severity.HINT] = vim.g.diag_symbol_hint,
			[vim.diagnostic.severity.ERROR] = vim.g.diag_symbol_error,
			[vim.diagnostic.severity.INFO] = vim.g.diag_symbol_info,
			[vim.diagnostic.severity.WARN] = vim.g.diag_symbol_warn,
		},
	},
})

map("n", "gh", vim.diagnostic.open_float)
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end)
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end)
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(e)
		vim.bo[e.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
		map("n", "gq", vim.diagnostic.setqflist)
		map("n", "gQ", vim.diagnostic.setloclist)
		map("n", "gd", vim.lsp.buf.definition)
		map("n", "gD", vim.lsp.buf.declaration)
		map("n", "gwd", ":vsplit | lua vim.lsp.buf.definition()<cr>")
		map("n", "gwD", ":vsplit | lua vim.lsp.buf.declaration()<cr>")
		map("n", "gt", vim.lsp.buf.type_definition)
		map("n", "gi", vim.lsp.buf.implementation)
		map("n", "gr", vim.lsp.buf.references)
		map("n", "gn", vim.lsp.buf.rename)
		map("n", "g.", vim.lsp.buf.code_action)
		map("n", "<leader>hi", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end)
		map({ "i", "s" }, "<c-s>", vim.lsp.buf.signature_help)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.rs" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- DAP
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

map("n", "<leader>dt", function()
	dv.toggle()
end)
map("n", "<leader>db", function()
	dap.toggle_breakpoint()
end)
map("n", "<leader>dl", function()
	dap.continue()
end)
map("n", "<leader>dj", function()
	dap.step_into()
end)
map("n", "<leader>dk", function()
	dap.step_over()
end)
map("n", "<leader>dt", function()
	if vim.bo.filetype == "python" then
		require("dap-python").test_method()
	elseif vim.bo.filetype == "go" then
		require("dap-go").debug_test()
	end
end)
