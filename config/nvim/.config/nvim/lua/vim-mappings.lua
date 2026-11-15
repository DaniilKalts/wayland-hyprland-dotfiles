vim.api.nvim_set_keymap("i", "jk", "<ESC>", { noremap = true, silent = true, desc = "Exit Insert Mode" })

vim.api.nvim_set_keymap("n", "hs", ":noh<CR>", { noremap = true, silent = true, desc = "Disable Search Highlighting" })

vim.api.nvim_set_keymap(
  "v",
  "<C-s>",
  ":Silicon<CR>",
  { noremap = true, silent = true, desc = "Take Snapshot with Silicon" }
)

vim.api.nvim_set_keymap(
  "n",
  "<C-m>",
  ":lua ToggleAlpha()<CR>",
  { noremap = true, silent = true, desc = "Toggle Alpha Dashboard" }
)

vim.api.nvim_set_keymap(
  "n",
  "<C-e>",
  ":Neotree toggle<CR>",
  { noremap = true, silent = true, desc = "Toggle Neo-tree" }
)

vim.api.nvim_set_keymap(
  "n",
  "mp",
  ":MarkdownPreviewToggle<CR>",
  { noremap = true, silent = true, desc = "Toggle Markdown Preview" }
)

vim.api.nvim_set_keymap(
  "n",
  "<C-p>",
  [[<cmd>lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h') })<CR>]],
  { noremap = true, silent = true, desc = "Telescope Find Files" }
)

vim.api.nvim_set_keymap(
  "n",
  "<C-g>",
  [[<cmd>lua require('telescope.builtin').live_grep({ cwd = vim.fn.expand('%:p:h') })<CR>]],
  { noremap = true, silent = true, desc = "Telescope Live Grep" }
)

vim.api.nvim_set_keymap(
  "n",
  "<S-Tab>",
  "<Cmd>BufferLineCyclePrev<CR>",
  { noremap = true, silent = true, desc = "Previous Buffer" }
)
vim.api.nvim_set_keymap(
  "n",
  "<Tab>",
  "<Cmd>BufferLineCycleNext<CR>",
  { noremap = true, silent = true, desc = "Next Buffer" }
)

function CloseBufferOrSwitchToAlpha()
  local buf_count = vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 }))
  if buf_count > 1 then
    vim.cmd("bprev")
    vim.cmd("bdelete #")
  else
    local current_buf = vim.api.nvim_get_current_buf()
    vim.cmd("Alpha")
    vim.cmd("bdelete " .. current_buf)
  end
end

vim.api.nvim_set_keymap(
  "n",
  "<leader>w",
  ":lua CloseBufferOrSwitchToAlpha()<CR>",
  { noremap = true, silent = true, desc = "Close Buffer or Switch to Alpha" }
)

for i = 1, 9 do
  vim.api.nvim_set_keymap(
    "n",
    "<leader>" .. tostring(i),
    "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>",
    { noremap = true, silent = true, desc = "Go to Buffer " .. i }
  )
end
vim.api.nvim_set_keymap(
  "n",
  "<leader>0",
  "<Cmd>BufferLineGoToBuffer -1<CR>",
  { noremap = true, silent = true, desc = "Go to Last Buffer" }
)

vim.keymap.set("n", "=", ":vertical resize +5<CR>", { noremap = true, silent = true, desc = "Increase Neo-tree Width" })
vim.keymap.set("n", "-", ":vertical resize -5<CR>", { noremap = true, silent = true, desc = "Decrease Neo-tree Width" })
