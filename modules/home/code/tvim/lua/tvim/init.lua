local function init()
  require("mini.extra").setup()
  require("tvim.vimsettings").init()
  require("tvim.ui").init()
  require("tvim.navigation").init()
  require("tvim.tools").init()
  require("tvim.lsp").init()
  require("tvim.dap").init()
end

return {
  init = init,
}
