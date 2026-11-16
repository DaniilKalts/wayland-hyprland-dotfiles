-- The plugin maps <C-h/j/k/l> in normal mode itself; only terminal mode needs help.
return {
  "christoomey/vim-tmux-navigator",
  config = function()
    for key, direction in pairs({ h = "Left", j = "Down", k = "Up", l = "Right" }) do
      vim.keymap.set(
        "t",
        "<C-" .. key .. ">",
        [[<C-\><C-n><Cmd>TmuxNavigate]] .. direction .. "<CR>",
        { silent = true, desc = "Navigate " .. direction:lower() }
      )
    end
  end,
}
