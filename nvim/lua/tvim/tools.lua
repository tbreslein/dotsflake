Later(function()
  Add("stevearc/conform.nvim")
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

  Add("mfussenegger/nvim-lint")
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
end)
