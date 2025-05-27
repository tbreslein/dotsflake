local function init()
  require("mini.pick").setup({
    window = {
      config = function()
        return { width = vim.o.columns - 2 }
      end,
    },
  })
  vim.keymap.set("n", "<leader>ff", function()
    local in_git = vim.system({ "git", "rev-parse", "--is-inside-worktree" }):wait()
    if in_git.code == 0 then
      MiniPick.builtin.files({ tool = "git" })
    else
      MiniPick.builtin.files()
    end
  end, { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>fs", MiniPick.builtin.grep_live, { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>fh", MiniPick.builtin.help, { noremap = true, silent = true })
  vim.keymap.set("n", "<leader>fb", MiniPick.builtin.buffers, { noremap = true, silent = true })
  vim.ui.select = MiniPick.ui_select

  local mini_files = require("mini.files")
  mini_files.setup()
  vim.keymap.set("n", "<leader>fo", function()
    mini_files.open(vim.api.nvim_buf_get_name(0))
  end, { noremap = true, silent = true })

  require("tmux").setup()

  local harpoon = require("harpoon")
  harpoon:setup({
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
    },
  })
  vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
  end)
  vim.keymap.set("n", "<leader>e", function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
  end)
  vim.keymap.set("n", "<a-s>", function()
    harpoon:list():select(1)
  end)
  vim.keymap.set("n", "<a-t>", function()
    harpoon:list():select(2)
  end)
  vim.keymap.set("n", "<a-r>", function()
    harpoon:list():select(3)
  end)
  vim.keymap.set("n", "<a-n>", function()
    harpoon:list():select(4)
  end)
end

return { init = init }
