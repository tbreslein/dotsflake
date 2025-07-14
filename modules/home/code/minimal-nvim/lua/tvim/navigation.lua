vim.opt.grepprg = "rg --vimgrep --ignore-file=.gitignore --iglob='!.git/' --iglob='!**/*.ipynb'"

local fuzzy = require("tvim.fuzzy")

local function file_search(fd_flags)
  fuzzy.fuzzy_search("fd " .. fd_flags .. " | sk --reverse", function(stdout)
    local selected, _ = stdout:gsub("\n", "")
    vim.cmd("bd!")
    vim.cmd("e " .. selected)
  end)
end

vim.keymap.set("n", "<leader>ff", function()
  file_search("")
end)
vim.keymap.set("n", "<leader>fg", function()
  file_search("-u")
end)

vim.keymap.set("n", "<leader>fs", function()
  fuzzy.fuzzy_search([[sk --reverse -m --ansi -i -c 'rg --color=always --line-number "{}"']], function(stdout)
    local lines = vim.split(stdout, "\n", { plain = true, trimempty = true })
    vim.cmd("bd!")
    if #lines > 1 then
      vim.fn.setqflist({}, "r", { lines = lines })
      vim.cmd("copen")
    elseif #lines == 1 then
      vim.cmd("e " .. lines[1])
    end
  end)
end)
