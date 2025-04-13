local function init()
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

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>")
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
end

return { init = init }
