local function init()
local fzflua = require("fzf-lua")
fzflua.setup({
	winopts = {
		border = vim.g.borderstyle,
		preview = { layout = "vertical" },
	},
	fzf_opts = { ["--layout"] = false },
})
vim.keymap.set("n", "<leader>ff", fzflua.files, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>fs", fzflua.live_grep, { noremap = true, silent = true })

require("mini.move").setup({
	mappings = {
		left = "<M-h>",
		right = "<M-l>",
		down = "<M-j>",
		up = "<M-k>",

		line_left = nil,
		line_right = nil,
		line_down = nil,
		line_up = nil,
	},
})

local mini_files = require("mini.files")
mini_files.setup()
vim.keymap.set("n", "<leader>fp", function()
	mini_files.open(vim.api.nvim_buf_get_name(0))
end, { noremap = true, silent = true })

require("tmux").setup()

require("grapple").setup()
vim.keymap.set("n", "<leader>a", "<cmd>Grapple tag<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>e", "<cmd>Grapple toggle_tags<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-r>", "<cmd>Grapple select index=1<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-e>", "<cmd>Grapple select index=2<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-w>", "<cmd>Grapple select index=3<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-q>", "<cmd>Grapple select index=4<cr>", { noremap = true, silent = true })

require("grug-far").setup()
end

return { init = init }
