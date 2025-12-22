return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Disable semantic tokens in capabilities (use Tree-sitter only)
			capabilities.textDocument.semanticTokens = nil

			-- LSP servers to install
			local servers = {
				"lua_ls",
				"bashls",
				"docker_compose_language_service",
				"sqlls",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"pyright",
				"gopls",
				"clangd",
				"eslint",
			}

			require("mason-lspconfig").setup({
				ensure_installed = servers,
				automatic_installation = true,
			})

			-- Configure global defaults for all LSP servers (Neovim 0.11+)
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Enable all servers
			for _, server in ipairs(servers) do
				vim.lsp.enable(server)
			end

			-- Global LSP keymaps and settings via LspAttach autocmd
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					local bufnr = ev.buf
					local opts = { noremap = true, silent = true, buffer = bufnr }

					-- Disable semantic tokens on the client side as well
					if client then
						client.server_capabilities.semanticTokensProvider = nil
					end

					vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "<leader>rf", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

					-- Auto-format on save
					vim.api.nvim_create_autocmd("BufWritePre", {
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ async = false })
						end,
						desc = "Auto format on save",
					})

					-- ESLint auto-fix on save
					if client and client.name == "eslint" then
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "EslintFixAll",
						})
					end
				end,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
	},
}
