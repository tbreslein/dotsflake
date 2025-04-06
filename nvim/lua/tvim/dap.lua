Later(function()
  Add({
    source = "mfussenegger/nvim-dap",
    depends = {
      "igorlfs/nvim-dap-view",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
  })

  local dap, dv = require("dap"), require("dap-view")
  dv.setup()

  dap.listeners.before.attach["dap-view-config"] = function()
    dv.open()
  end
  dap.listeners.before.launch["dap-view-config"] = function()
    dv.open()
  end
  dap.listeners.before.event_terminated["dap-view-config"] = function()
    dv.close()
  end
  dap.listeners.before.event_exited["dap-view-config"] = function()
    dv.close()
  end

  require("dap-python").setup("python")
  require("dap-go").setup()

  Map("n", "<leader>dt", function()
    dv.toggle()
  end)
  Map("n", "<leader>db", function()
    dap.toggle_breakpoint()
  end)
  Map("n", "<leader>dl", function()
    dap.continue()
  end)
  Map("n", "<leader>dj", function()
    dap.step_into()
  end)
  Map("n", "<leader>dk", function()
    dap.step_over()
  end)
  Map("n", "<leader>dt", function()
    if vim.bo.filetype == "python" then
      require("dap-python").test_method()
    elseif vim.bo.filetype == "go" then
      require("dap-go").debug_test()
    end
  end)
end)
