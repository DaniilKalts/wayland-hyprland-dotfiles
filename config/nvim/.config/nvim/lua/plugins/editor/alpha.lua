return {
	"goolord/alpha-nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},

	config = function()
		local alpha = require("alpha")
		local dashboard = require("alpha.themes.dashboard")

		dashboard.section.header.val = {
			"███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
			"████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
			"██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
			"██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
			"██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
			"╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
		}

		dashboard.section.buttons.val = {
			dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
			dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
			dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
			dashboard.button("s", "  Settings", ":e $MYVIMRC<CR>"),
			dashboard.button("q", "󰅖  Quit NVIM", ":qa<CR>"),
		}

		local function calculate_padding()
			local total_lines = vim.o.lines
			local header_lines = #dashboard.section.header.val
			local buttons_lines = #dashboard.section.buttons.val
			local footer_lines = #dashboard.section.footer.val
			local content_lines = header_lines + buttons_lines + footer_lines + 6

			local padding_top = math.floor((total_lines - content_lines) / 2)
			return math.max(padding_top, 0)
		end

		local padding_top = calculate_padding()
		dashboard.config.layout = {
			{ type = "padding", val = padding_top },
			dashboard.section.header,
			{ type = "padding", val = 2 },
			dashboard.section.buttons,
			{ type = "padding", val = 2 },
			dashboard.section.footer,
		}

		vim.cmd([[colorscheme dracula]])
		vim.cmd([[
      hi AlphaHeader guifg=#bd93f9
      hi AlphaFooter guifg=#f8f8f2
      hi AlphaButton guifg=#50fa7b
      hi AlphaButtonShortcut guifg=#ffb86c
    ]])

		dashboard.section.header.opts = {
			position = "center",
			hl = "AlphaHeader",
		}
		dashboard.section.footer.opts = {
			position = "center",
			hl = "AlphaFooter",
		}
		for _, button in ipairs(dashboard.section.buttons.val) do
			button.opts.hl = "AlphaButton"
			button.opts.hl_shortcut = "AlphaButtonShortcut"
		end

		alpha.setup(dashboard.config)

		function ToggleAlpha()
			local bufnr = vim.fn.bufnr("%")
			if vim.api.nvim_buf_get_name(bufnr) == "" and vim.bo[bufnr].buftype == "" then
				vim.cmd("Alpha")
			else
				vim.cmd("enew")
			end
		end
	end,
}
