vim.o.termguicolors = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazypath)

require("vim-options")

require("vim-mappings")

require("lazy").setup({
	require("plugins.ui.colorizer"),
	require("plugins.ui.dracula"),
	require("plugins.ui.treesitter"),

	require("plugins.languages.lsp"),
	require("plugins.languages.completions"),

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

	require("plugins.tools.markdown-preview"),
	require("plugins.tools.project"),
	require("plugins.tools.silicon"),
	require("plugins.tools.todo-comments"),
}, {
	git = {
		url_format = "https://github.com/%s.git",
		timeout = 300,
	},
})
