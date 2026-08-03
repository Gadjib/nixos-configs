local nix = require("config.nix")
vim.opt.runtimepath:prepend(nix.lazy)

vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_cmp = "nvim-cmp"
vim.g.lazyvim_colorscheme = "catppuccin-" .. nix.theme

local specs = {
  {
    "LazyVim/LazyVim",
    dir = nix.lazyvim,
    import = "lazyvim.plugins",
  },
  { import = "lazyvim.plugins.extras.coding.nvim-cmp" },
  { import = "lazyvim.plugins.extras.coding.luasnip" },
  { import = "lazyvim.plugins.extras.dap.core" },
  { import = "lazyvim.plugins.extras.test.core" },
  { import = "lazyvim.plugins.extras.lang.clangd" },
  { import = "lazyvim.plugins.extras.lang.cmake" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.tex" },
  { import = "plugins" },
}

vim.list_extend(specs, require("config.local_plugins"))

require("lazy").setup(specs, {
  defaults = { lazy = true },
  install = {
    colorscheme = { "catppuccin-macchiato" },
    missing = false,
  },
  checker = { enabled = false },
  change_detection = { enabled = false, notify = false },
  performance = {
    reset_packpath = false,
    rtp = {
      reset = false,
    },
  },
  lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
})

-- Headless sessions do not always emit VeryLazy; loading this module here is
-- idempotent and keeps project/run commands available in every Neovim mode.
require("config.keymaps")
