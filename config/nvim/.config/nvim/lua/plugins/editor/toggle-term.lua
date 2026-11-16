return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 10,
      open_mapping = [[<C-t>]],
      shade_terminals = false,
      direction = "horizontal",
      shell = "zsh",
      -- Follow Neovim's working directory the next time a terminal is opened.
      autochdir = true,
      highlights = {
        Normal = {
          guibg = "#282a36",
          guifg = "#f8f8f2",
        },
        NormalFloat = {
          link = "Normal",
        },
        FloatBorder = {
          guifg = "#6272a4",
          guibg = "#282a36",
        },
      },
    })

    local map = vim.keymap.set

    -- Terminals 1-3 open horizontally, 4-6 vertically.
    for id = 1, 6 do
      local direction = id <= 3 and "horizontal" or "vertical"
      map(
        { "n", "t" },
        "<M-" .. id .. ">",
        "<Cmd>" .. id .. "ToggleTerm direction=" .. direction .. "<CR>",
        { desc = "Toggle terminal " .. id }
      )
    end

    map("n", "<M-=>", "<Cmd>resize +5<CR>", { desc = "Grow terminal" })
    map("n", "<M-->", "<Cmd>resize -5<CR>", { desc = "Shrink terminal" })
    map("t", "<M-=>", [[<C-\><C-n><Cmd>resize +5<CR>]], { desc = "Grow terminal" })
    map("t", "<M-->", [[<C-\><C-n><Cmd>resize -5<CR>]], { desc = "Shrink terminal" })
  end,
}
