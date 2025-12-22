return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			-- Enable Tree-sitter highlighting for all buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})

			-- Enable Tree-sitter indentation
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				strategy = {
					[""] = rainbow_delimiters.strategy["global"],
					vim = rainbow_delimiters.strategy["local"],
				},
				query = {
					[""] = "rainbow-delimiters",
					lua = "rainbow-blocks",
				},
				highlight = {
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
					"RainbowDelimiterGreen",
					"RainbowDelimiterYellow",
					"RainbowDelimiterOrange",
					"RainbowDelimiterRed",
				},
			}
		end,
	},
}
