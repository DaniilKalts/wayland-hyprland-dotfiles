local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Options set the leader key, so they must load before any mapping.
require("vim-options")
require("vim-mappings")
require("vim-autocmds")

require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.languages" },
  { import = "plugins.editor" },
  { import = "plugins.tools" },
}, {
  git = { timeout = 300 },
})
