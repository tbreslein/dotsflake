function Map(mode, keys, action, opts, desc)
	vim.keymap.set(
		mode,
		keys,
		action,
		vim.tbl_extend("keep", opts or {}, { noremap = true, silent = true, desc = desc })
	)
end

require("vimsettings")
require("ui")
require("navigation")
require("tools")
require("lsp")
require("dap")
