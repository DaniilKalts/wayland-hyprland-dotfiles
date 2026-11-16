return {
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
        enforce_regular_tabs = true,
      },
    })

    local map = vim.keymap.set

    map("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    map("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

    for i = 1, 9 do
      map("n", "<leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
    end
    map("n", "<leader>0", "<Cmd>BufferLineGoToBuffer -1<CR>", { desc = "Go to last buffer" })
  end,
}
