local root_markers = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" }

-- Keep the working directory at the root of the project the current file is in.
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("UserProjectRoot", { clear = true }),
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" or vim.api.nvim_buf_get_name(args.buf) == "" then
      return
    end

    local root = vim.fs.root(args.buf, root_markers)
    if root and root ~= vim.fn.getcwd() then
      vim.fn.chdir(root)
    end
  end,
})
