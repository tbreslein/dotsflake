-- local M = {}
-- local function M.init()
-- 	require("tvim.vimsettings").init()
-- end
--
-- return M
local function init()
	require("tvim.vimsettings").init()
	require("tvim.ui").init()
	require("tvim.navigation").init()
	require("tvim.tools").init()
	require("tvim.lsp").init()
	require("tvim.dap").init()
end

return {
	init = init
}
