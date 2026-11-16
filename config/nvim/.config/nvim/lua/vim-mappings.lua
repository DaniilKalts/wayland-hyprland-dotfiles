-- Core mappings only; plugin mappings live next to their plugin in lua/plugins/.
local map = vim.keymap.set

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "<leader>h", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

-- <Tab> is mapped by bufferline; without this <C-i> would trigger it too.
map("n", "<C-i>", "<C-i>", { desc = "Jump forward in the jumplist" })

map("n", "<leader>=", "<Cmd>vertical resize +5<CR>", { desc = "Widen window" })
map("n", "<leader>-", "<Cmd>vertical resize -5<CR>", { desc = "Narrow window" })
