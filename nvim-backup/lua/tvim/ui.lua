Now(function()
  Add("sainnhe/gruvbox-material")
  vim.g.gruvbox_material_enable_italic = 1
  vim.g.gruvbox_material_enable_bold = 1
  vim.g.gruvbox_material_better_performance = 1
  vim.g.gruvbox_material_ui_contrast = "high"
  vim.g.gruvbox_material_diagnostic_virtual_text = "highlighted"
  vim.g.gruvbox_material_dim_inactive_windows = 1
  vim.g.gruvbox_material_float_style = "dim"
  vim.g.gruvbox_material_transparent_background = 2
  -- vim.o.background = "light"
  -- vim.g.gruvbox_material_foreground = "original"
  -- vim.g.gruvbox_material_background = "soft"
  vim.o.background = "dark"
  vim.cmd.colorscheme("gruvbox-material")

  package.preload["nvim-web-devicons"] = function()
    package.loaded["nvim-web-devicons"] = {}
    require("mini.icons").mock_nvim_web_devicons()
    return package.loaded["nvim-web-devicons"]
  end
end)

Later(function()
  Add({
    source = "nvim-treesitter/nvim-treesitter",
    depends = { "nvim-treesitter/nvim-treesitter-context" },
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  })
  Add("nvim-treesitter/nvim-treesitter-textobjects")

  require("nvim-treesitter.configs").setup({
    ensure_installed = {
      "lua",
      "vimdoc",
      "rust",
      "zig",
      "c",
      "cpp",
      "python",
      "go",
      "haskell",
      "astro",
      "javascript",
      "typescript",
      "toml",
      "yaml",
      "markdown",
      "markdown_inline",
    },
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

  Add("MeanderingProgrammer/render-markdown.nvim")
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

  Add({
    source = "NeogitOrg/neogit",
    depends = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
  })
  require("neogit").setup()
  Map("n", "<leader>gg", "<cmd>Neogit<cr>")

  Add({
    source = "nvim-orgmode/orgmode",
    depends = {
      "chipsenkbeil/org-roam.nvim",
      "nvim-orgmode/org-bullets.nvim",
    },
  })

  require("orgmode").setup({
    org_agenda_files = "~/notes/**/*",
    org_default_notes_file = "~/notes/refile.org",
  })
  require("org-bullets").setup()

  local build_sniprun = function(params)
    vim.notify("Building sniprun", vim.log.levels.INFO)
    local obj = vim.system({ "sh", "./install.sh" }, { cwd = params.path }):wait()
    if obj.code == 0 then
      vim.notify("Building sniprun done", vim.log.levels.INFO)
    else
      vim.notify("Building sniprun failed", vim.log.levels.ERROR)
    end
  end
  Add({ source = "michaelb/sniprun", hooks = { post_install = build_sniprun } })
end)
