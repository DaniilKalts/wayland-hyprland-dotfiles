return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local severity = vim.diagnostic.severity

      local function useful_code_actions()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = {
              "quickfix",
              "refactor",
              "source.fixAll",
              "source.organizeImports",
            },
          },
        })
      end

      local function all_code_actions()
        vim.lsp.buf.code_action({ apply = true })
      end

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
        "jdtls",
      }

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Installs the servers and enables each one (automatic_enable).
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })

      vim.diagnostic.config({
        virtual_text = true,
        signs = {
          text = {
            [severity.ERROR] = "✘",
            [severity.WARN] = "",
            [severity.HINT] = "",
            [severity.INFO] = "",
          },
          numhl = {
            [severity.ERROR] = "DiagnosticSignError",
            [severity.WARN] = "DiagnosticSignWarn",
            [severity.HINT] = "DiagnosticSignHint",
            [severity.INFO] = "DiagnosticSignInfo",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      local format_group = vim.api.nvim_create_augroup("UserLspFormat", { clear = true })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local bufnr = ev.buf
          local opts = { noremap = true, silent = true, buffer = bufnr }

          -- Highlighting comes from Tree-sitter only.
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end

          vim.keymap.set("n", "<leader>i", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>R", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>a", useful_code_actions, opts)
          vim.keymap.set("n", "<leader>A", all_code_actions, opts)
          vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)

          -- One autocmd per buffer, however many clients attach to it.
          vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            buffer = bufnr,
            callback = function()
              if vim.fn.exists(":LspEslintFixAll") == 2 then
                vim.cmd("LspEslintFixAll")
              end
              vim.lsp.buf.format({ async = false })
            end,
            desc = "Auto format on save",
          })
        end,
      })
    end,
  },
}
