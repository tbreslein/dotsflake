local fuzzy = require("tvim.fuzzy")

local function file_search(fd_flags)
  fuzzy.fuzzy_search("fd " .. fd_flags .. " | sk", function(stdout)
    local selected, _ = stdout:gsub('\n', '')
    vim.cmd('bd!')
    vim.cmd('e ' .. selected)
  end)
end

vim.keymap.set("n", "<leader>ff", function()
  file_search("")
end)
vim.keymap.set("n", "<leader>fg", function()
  file_search("-u")
end)

vim.keymap.set("n", "<leader>fs", function()
  fuzzy.fuzzy_search(
    [[sk -m --ansi -i -c 'rg --color=always --line-number "{}"']],
    function(stdout)
      local lines = vim.split(stdout, "\n", {plain=true, trimempty=true})
      -- vim.print(lines)
      if #lines > 0 then
        vim.fn.setqflist({}, 'r', {lines = lines})
        vim.cmd('bd!')
        vim.cmd("copen")
      end

      -- for k, v in ipairs(lines) do
      --   vim.print(k, v)
      -- end
      -- print(#lines)
      -- local selected, _ = stdout:gsub('\n', '')
      -- vim.cmd('bd!')
      -- vim.cmd('e ' .. selected)
    end)
end)
