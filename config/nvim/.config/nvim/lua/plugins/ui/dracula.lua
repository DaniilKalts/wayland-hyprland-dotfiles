return {
  "Mofiqul/dracula.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("dracula").setup({
      show_end_of_buffer = false,
      transparent_bg = false,
      italic_comment = true,
      -- Highlights for other plugins live here so they survive a colorscheme reload.
      overrides = function(colors)
        return {
          NeoTreeTitleBar = { bg = colors.purple, fg = colors.menu },
          NeoTreeFileIcon = { fg = colors.purple },
          NeoTreeDirectoryIcon = { fg = colors.purple },
          NeoTreeDirectoryName = { fg = colors.purple },
          NeoTreeCursorLine = { bg = colors.selection },

          AlphaHeader = { fg = colors.purple },
          AlphaFooter = { fg = colors.fg },
          AlphaButton = { fg = colors.green },
          AlphaButtonShortcut = { fg = colors.orange },
        }
      end,
    })

    vim.cmd.colorscheme("dracula")
  end,
}
