return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					numbers = "ordinal",
					offsets = {
						{
							filetype = "neo-tree",
							text = "",
							separator = true,
							text_align = "left",
						},
					},
					show_buffer_close_icons = true,
					show_tab_indicators = true,
					enforce_regular_tabs = true,
					always_show_bufferline = true,
				},
			})
		end,
	},
}
