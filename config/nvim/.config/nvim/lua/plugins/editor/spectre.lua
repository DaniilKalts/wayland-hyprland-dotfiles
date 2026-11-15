return {
	"MagicDuck/grug-far.nvim",
	config = function()
		require("grug-far").setup({
			engines = {
				ripgrep = {
					extraArgs = "--hidden --glob=!.git/** --glob=!node_modules/** --glob=!vendor/**",
				},
			},
			windowCreationCommand = "vsplit",
			keymaps = {
				replace = { n = "<localleader>r" },
				qflist = { n = "<localleader>q" },
				syncLocations = { n = "<localleader>s" },
				syncLine = { n = "<localleader>l" },
				close = { n = "q" },
				historyOpen = { n = "<localleader>t" },
				historyAdd = { n = "<localleader>a" },
				refresh = { n = "<localleader>f" },
				gotoLocation = { n = "<enter>" },
				pickHistoryEntry = { n = "<enter>" },
			},
		})

		vim.keymap.set("n", "<C-s>", function()
			require("grug-far").open()
		end, { desc = "Open grug-far for search and replace" })

		vim.keymap.set("n", "<leader>sw", function()
			require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
		end, { desc = "Search current word" })
	end,
}
