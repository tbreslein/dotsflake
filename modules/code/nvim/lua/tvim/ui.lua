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

  local hipatterns = require("mini.hipatterns")
  local hi_words = require("mini.extra").gen_highlighter.words
  hipatterns.setup({
    highlighters = {
      todo = hi_words({ "TODO" }, "MiniHipatternsTodo"),
      fixme = hi_words({ "FIXME" }, "MiniHipatternsFixme"),
      hack = hi_words({ "HACK" }, "MiniHipatternsHack"),
      note = hi_words({ "NOTE" }, "MiniHipatternsNote"),
      perf = hi_words({ "PERF" }, "MiniHipatternsNote"),
      warn = hi_words({ "WARN" }, "MiniHipatternsNote"),
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
  require("mini.trailspace").setup()

  vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>")

  local notify = require("mini.notify")
  notify.setup()
  vim.notify = notify.make_notify({
    ERROR = { duration = 5000 },
    WARN = { duration = 3000 },
    INFO = { duration = 2000 },
  })
end

return { init = init }
