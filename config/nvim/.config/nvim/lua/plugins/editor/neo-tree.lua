return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      window = {
        width = 35,
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        group_empty_dirs = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = {
          hide_dotfiles = true,
          hide_gitignored = true,
        },
      },
    })

    vim.keymap.set("n", "<C-e>", "<Cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
  end,
}
