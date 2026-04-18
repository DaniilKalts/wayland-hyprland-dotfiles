local excluded_filetypes = {
	toggleterm = true,
}

local function has_treesitter_parser(bufnr)
	if vim.bo[bufnr].buftype ~= "" then
		return false
	end

	local filetype = vim.bo[bufnr].filetype
	if filetype == "" or excluded_filetypes[filetype] then
		return false
	end

	local ok, language = pcall(vim.treesitter.language.get_lang, filetype)
	if not ok or not language then
		return false
	end

	return pcall(vim.treesitter.language.add, language)
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()

			-- Enable Tree-sitter highlighting for all buffers
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(args)
					if has_treesitter_parser(args.buf) then
						pcall(vim.treesitter.start, args.buf)
					end
				end,
			})

			-- Enable Tree-sitter indentation
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "*",
				callback = function(args)
					if has_treesitter_parser(args.buf) then
						vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	},
	{
		"HiPhish/rainbow-delimiters.nvim",
		config = function()
			local rainbow_delimiters = require("rainbow-delimiters")

			vim.g.rainbow_delimiters = {
				blacklist = { "toggleterm" },
				condition = has_treesitter_parser,
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
