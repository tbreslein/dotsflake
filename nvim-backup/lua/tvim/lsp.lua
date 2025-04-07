Later(function()
  Add("neovim/nvim-lspconfig")
  Add({ source = "mrcjkb/rustaceanvim", depends = { "mfussenegger/nvim-dap" } })
  vim.g.rustaceanvim = { server = { default_settings = { ["rust-analyzer"] = { check = { command = "check" } } } } }

  Add({
    source = "Saghen/blink.cmp",
    depends = { "rafamadriz/friendly-snippets" },
    checkout = "v1.0.0",
  })

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
      local env = vim.trim(vim.fn.system('cd "' .. (root_dir or ".") .. '"; poetry env info --executable 2>/dev/null'))
      if string.len(env) > 0 then
        config.settings.python.pythonPath = env
      end
    end,
  })

  Add("rachartier/tiny-inline-diagnostic.nvim")
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

  Map("n", "gh", vim.diagnostic.open_float)
  Map("n", "]d", function()
    vim.diagnostic.jump({ count = 1 })
  end)
  Map("n", "[d", function()
    vim.diagnostic.jump({ count = -1 })
  end)
  vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(e)
      vim.bo[e.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
      Map("n", "gq", vim.diagnostic.setqflist)
      Map("n", "gQ", vim.diagnostic.setloclist)
      Map("n", "gd", vim.lsp.buf.definition)
      Map("n", "gD", vim.lsp.buf.declaration)
      Map("n", "gwd", ":vsplit | lua vim.lsp.buf.definition()<cr>")
      Map("n", "gwD", ":vsplit | lua vim.lsp.buf.declaration()<cr>")
      Map("n", "gt", vim.lsp.buf.type_definition)
      Map("n", "gi", vim.lsp.buf.implementation)
      Map("n", "gr", vim.lsp.buf.references)
      Map("n", "gn", vim.lsp.buf.rename)
      Map("n", "g.", vim.lsp.buf.code_action)
      Map("n", "<leader>hi", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end)
      Map({ "i", "s" }, "<c-s>", vim.lsp.buf.signature_help)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.rs" },
    callback = function()
      vim.lsp.buf.format({ async = false })
    end,
  })
end)
