-- Enable true color support
vim.o.termguicolors = true

-- Path to store lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Add lazypath to runtimepath
vim.opt.rtp:prepend(lazypath)

-- Setup personal options
require("vim-options")

-- Setup personal key mappings
require("vim-mappings")

-- Initialize lazy.nvim and setup plugins
require("lazy").setup({
	-- UI Plugins
	require("plugins.ui.colorizer"),
	require("plugins.ui.dracula"),
	require("plugins.ui.treesitter"),

	-- Language Plugins
	require("plugins.languages.lsp"),
	require("plugins.languages.completions"),

	-- Editor Enhancements
	require("plugins.editor.alpha"),
	require("plugins.editor.bufferline"),
	require("plugins.editor.comment"),
	require("plugins.editor.lualine"),
	require("plugins.editor.mini"),
	require("plugins.editor.neo-tree"),
	require("plugins.editor.spectre"),
	require("plugins.editor.telescope"),
	require("plugins.editor.tmux-navigator"),
	require("plugins.editor.toggle-term"),
	require("plugins.editor.visual-multi"),

	-- Useful Tools
	require("plugins.tools.markdown-preview"),
	require("plugins.tools.project"),
	require("plugins.tools.silicon"),
	require("plugins.tools.todo-comments"),
	require("plugins.tools.wakatime"),
}, {
	-- Git configuration for lazy.nvim
	git = {
		url_format = "https://github.com/%s.git",
		timeout = 300, -- 5 minutes timeout for large repos
	},
})
