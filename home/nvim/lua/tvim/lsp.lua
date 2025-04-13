local function init()
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

vim.keymap.set("n", "gh", vim.diagnostic.open_float)
vim.keymap.set("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end)
vim.keymap.set("n", "[d", function()
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
		vim.keymap.set("n", "gr", vim.lsp.buf.references)
		vim.keymap.set("n", "gn", vim.lsp.buf.rename)
		vim.keymap.set("n", "g.", vim.lsp.buf.code_action)
		vim.keymap.set("n", "<leader>hi", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end)
		vim.keymap.set({ "i", "s" }, "<c-s>", vim.lsp.buf.signature_help)
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.rs" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
end

return { init = init }
