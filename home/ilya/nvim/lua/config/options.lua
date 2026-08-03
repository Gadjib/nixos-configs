local nix = require("config.nix")

vim.g.lazyvim_colorscheme = "catppuccin-" .. nix.theme
vim.g.autoformat = true
vim.g.trouble_lualine = false

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.clipboard = "unnamedplus"
