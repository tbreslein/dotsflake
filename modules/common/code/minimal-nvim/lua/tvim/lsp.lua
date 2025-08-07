local lspconfig, blink = require("lspconfig"), require("blink.cmp")

blink.setup({
  keymap = {
    preset = "default",
    ["<c-j>"] = { "select_next" },
    ["<c-k>"] = { "select_prev" },
    ["<c-l>"] = { "accept" },
    ["<c-i>"] = { "scroll_documentation_up" },
    ["<c-u>"] = { "scroll_documentation_down" },
    ["<c-o>"] = { "snippet_forward", "fallback" },
    ["<c-y>"] = { "snippet_backward", "fallback" },
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
    default = { "lsp", "path", "buffer" },
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

lspconfig.bashls.setup({ capabilities = lsp_capabilities })
lspconfig.clangd.setup({ capabilities = lsp_capabilities })
lspconfig.dockerls.setup({ capabilities = lsp_capabilities })
lspconfig.lua_ls.setup({ capabilities = lsp_capabilities })
lspconfig.nixd.setup({ capabilities = lsp_capabilities })
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
