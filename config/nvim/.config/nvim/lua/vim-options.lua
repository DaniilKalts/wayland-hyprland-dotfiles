vim.g.mapleader = " "

local opt = vim.opt

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
-- Keep the cursor line vertically centred.
opt.scrolloff = 999

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

opt.ignorecase = true
opt.smartcase = true

opt.clipboard = "unnamedplus"
opt.undofile = true
