local nix = require("config.nix")

return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin-" .. nix.theme },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    dir = nix.catppuccin,
    lazy = false,
    priority = 1000,
    opts = {
      flavour = nix.theme,
      term_colors = true,
      integrations = {
        cmp = true,
        dap = true,
        dap_ui = true,
        gitsigns = true,
        native_lsp = { enabled = true },
        neotest = true,
        noice = true,
        snacks = true,
        treesitter = true,
        treesitter_context = true,
        trouble = true,
        which_key = true,
      },
    },
  },
  { "folke/tokyonight.nvim", enabled = false },
}
