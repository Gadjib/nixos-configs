{ pkgs, lib, ... }:

let
  appearance = import ../appearance.nix { inherit pkgs; };
  russianSpell = pkgs.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.spl";
    hash = "sha256-6y0714ogILMLzAp8/r2s6/t6QnWBEU9muIpXeubaxU0=";
  };
  russianSuggestions = pkgs.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.sug";
    hash = "sha256-6r2GForYXVv7gGiAjPeYK6sDdK/CmctJ7MidcWFvOTs=";
  };
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (parsers: [
    parsers.bash
    parsers.bibtex
    parsers.c
    parsers.cmake
    parsers.cpp
    parsers.json
    parsers.latex
    parsers.lua
    parsers.markdown
    parsers.markdown_inline
    parsers.ninja
    parsers.python
    parsers.query
    parsers.regex
    parsers.rst
    parsers.toml
    parsers.vim
    parsers.vimdoc
    parsers.yaml
  ]);
  treesitterPlugin = pkgs.symlinkJoin {
    name = "nvim-treesitter";
    paths = [ treesitter ] ++ treesitter.dependencies;
  };
  debugPython = pkgs.python3.withPackages (pythonPackages: [
    pythonPackages.debugpy
    pythonPackages.pytest
  ]);
  vscodeLldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;
  neotestPython = pkgs.symlinkJoin {
    # neotest-python locates its helper by the literal path suffix
    # "neotest-python/neotest.py".
    name = "neotest-python";
    paths = [ pkgs.vimPlugins.neotest-python ];
  };
  codelldb = pkgs.writeShellScriptBin "codelldb" ''
    exec ${vscodeLldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb "$@"
  '';
  localPlugins = [
    { repo = "MagicDuck/grug-far.nvim"; package = pkgs.vimPlugins.grug-far-nvim; }
    { repo = "MunifTanjim/nui.nvim"; package = pkgs.vimPlugins.nui-nvim; }
    { repo = "L3MON4D3/LuaSnip"; package = pkgs.vimPlugins.luasnip; }
    { repo = "Civitasv/cmake-tools.nvim"; package = pkgs.vimPlugins.cmake-tools-nvim; }
    { repo = "akinsho/bufferline.nvim"; package = pkgs.vimPlugins.bufferline-nvim; }
    { repo = "folke/flash.nvim"; package = pkgs.vimPlugins.flash-nvim; }
    { repo = "folke/lazydev.nvim"; package = pkgs.vimPlugins.lazydev-nvim; }
    { repo = "folke/noice.nvim"; package = pkgs.vimPlugins.noice-nvim; }
    { repo = "folke/persistence.nvim"; package = pkgs.vimPlugins.persistence-nvim; }
    { repo = "folke/snacks.nvim"; package = pkgs.vimPlugins.snacks-nvim; }
    { repo = "folke/todo-comments.nvim"; package = pkgs.vimPlugins.todo-comments-nvim; }
    { repo = "folke/trouble.nvim"; package = pkgs.vimPlugins.trouble-nvim; }
    { repo = "folke/ts-comments.nvim"; package = pkgs.vimPlugins.ts-comments-nvim; }
    { repo = "folke/which-key.nvim"; package = pkgs.vimPlugins.which-key-nvim; }
    { repo = "hrsh7th/cmp-buffer"; package = pkgs.vimPlugins.cmp-buffer; }
    { repo = "hrsh7th/cmp-nvim-lsp"; package = pkgs.vimPlugins.cmp-nvim-lsp; }
    { repo = "hrsh7th/cmp-nvim-lsp-signature-help"; package = pkgs.vimPlugins.cmp-nvim-lsp-signature-help; }
    { repo = "hrsh7th/cmp-path"; package = pkgs.vimPlugins.cmp-path; }
    { repo = "hrsh7th/cmp-vimtex"; package = pkgs.vimPlugins.cmp-vimtex; }
    { repo = "hrsh7th/nvim-cmp"; package = pkgs.vimPlugins.nvim-cmp; }
    { repo = "lervag/vimtex"; package = pkgs.vimPlugins.vimtex; }
    { repo = "lewis6991/gitsigns.nvim"; package = pkgs.vimPlugins.gitsigns-nvim; }
    { repo = "linux-cultist/venv-selector.nvim"; package = pkgs.vimPlugins.venv-selector-nvim; }
    { repo = "mfussenegger/nvim-dap"; package = pkgs.vimPlugins.nvim-dap; }
    { repo = "mfussenegger/nvim-dap-python"; package = pkgs.vimPlugins.nvim-dap-python; }
    { repo = "mfussenegger/nvim-lint"; package = pkgs.vimPlugins.nvim-lint; }
    { repo = "neovim/nvim-lspconfig"; package = pkgs.vimPlugins.nvim-lspconfig; }
    { repo = "nvim-lua/plenary.nvim"; package = pkgs.vimPlugins.plenary-nvim; }
    { repo = "nvim-lualine/lualine.nvim"; package = pkgs.vimPlugins.lualine-nvim; }
    { repo = "nvim-mini/mini.ai"; package = pkgs.vimPlugins.mini-ai; }
    { repo = "nvim-mini/mini.icons"; package = pkgs.vimPlugins.mini-icons; }
    { repo = "nvim-mini/mini.pairs"; package = pkgs.vimPlugins.mini-pairs; }
    { repo = "nvim-neotest/neotest"; package = pkgs.vimPlugins.neotest; }
    { repo = "orjangj/neotest-ctest"; package = pkgs.vimPlugins.neotest-ctest; }
    { repo = "alfaix/neotest-gtest"; package = pkgs.vimPlugins.neotest-gtest; }
    { repo = "nvim-neotest/neotest-python"; package = neotestPython; }
    { repo = "nvim-neotest/nvim-nio"; package = pkgs.vimPlugins.nvim-nio; }
    { repo = "nvim-treesitter/nvim-treesitter"; package = treesitterPlugin; }
    { repo = "nvim-treesitter/nvim-treesitter-textobjects"; package = pkgs.vimPlugins.nvim-treesitter-textobjects; }
    { repo = "p00f/clangd_extensions.nvim"; package = pkgs.vimPlugins.clangd_extensions-nvim; }
    { repo = "rafamadriz/friendly-snippets"; package = pkgs.vimPlugins.friendly-snippets; }
    { repo = "rcarriga/nvim-dap-ui"; package = pkgs.vimPlugins.nvim-dap-ui; }
    { repo = "saadparwaiz1/cmp_luasnip"; package = pkgs.vimPlugins.cmp_luasnip; }
    { repo = "stevearc/conform.nvim"; package = pkgs.vimPlugins.conform-nvim; }
    { repo = "theHamsta/nvim-dap-virtual-text"; package = pkgs.vimPlugins.nvim-dap-virtual-text; }
    { repo = "windwp/nvim-ts-autotag"; package = pkgs.vimPlugins.nvim-ts-autotag; }
  ];
  localPluginSpecs = lib.concatMapStringsSep "\n" (plugin: ''
    { ${builtins.toJSON plugin.repo}, dir = ${builtins.toJSON "${plugin.package}"} },
  '') localPlugins;
in
{
  xdg.configFile = {
    "nvim/spell/ru.utf-8.spl".source = russianSpell;
    "nvim/spell/ru.utf-8.sug".source = russianSuggestions;
    "nvim/lua/config/lazy.lua".source = ./lua/config/lazy.lua;
    "nvim/lua/config/options.lua".source = ./lua/config/options.lua;
    "nvim/lua/config/keymaps.lua".source = ./lua/config/keymaps.lua;
    "nvim/lua/config/autocmds.lua".source = ./lua/config/autocmds.lua;
    "nvim/lua/config/runner.lua".source = ./lua/config/runner.lua;
    "nvim/lua/plugins/theme.lua".source = ./lua/plugins/theme.lua;
    "nvim/lua/plugins/latex.lua".source = ./lua/plugins/latex.lua;
    "nvim/lua/plugins/ide.lua".source = ./lua/plugins/ide.lua;
    "nvim/lua/config/nix.lua".text = ''
      return {
        lazyvim = ${builtins.toJSON "${pkgs.vimPlugins.LazyVim}"},
        lazy = ${builtins.toJSON "${pkgs.vimPlugins.lazy-nvim}"},
        catppuccin = ${builtins.toJSON "${pkgs.vimPlugins.catppuccin-nvim}"},
        theme = ${builtins.toJSON appearance.gtk.variant},
        tools = {
          basedpyright = ${builtins.toJSON "${pkgs.basedpyright}/bin/basedpyright-langserver"},
          clang = ${builtins.toJSON "${pkgs.clang}/bin/clang"},
          clangd = ${builtins.toJSON "${pkgs.clang-tools}/bin/clangd"},
          clang_format = ${builtins.toJSON "${pkgs.clang-tools}/bin/clang-format"},
          clangxx = ${builtins.toJSON "${pkgs.clang}/bin/clang++"},
          codelldb = ${builtins.toJSON "${codelldb}/bin/codelldb"},
          debugpy_adapter = ${builtins.toJSON "${debugPython}/bin/debugpy-adapter"},
          python = ${builtins.toJSON "${debugPython}/bin/python"},
          ruff = ${builtins.toJSON "${pkgs.ruff}/bin/ruff"},
          texlab = ${builtins.toJSON "${pkgs.texlab}/bin/texlab"},
          ltex = ${builtins.toJSON "${pkgs.ltex-ls-plus}/bin/ltex-ls-plus"},
        },
      }
    '';
    "nvim/lua/config/local_plugins.lua".text = ''
      return {
      ${localPluginSpecs}
      }
    '';
  };

  home.packages = with pkgs; [
    basedpyright
    bear
    clang
    clang-tools
    cmake
    codelldb
    debugPython
    ltex-ls-plus
    neocmakelsp
    neovim-remote
    ninja
    poetry
    ruff
    texlab
    uv
    vscodeLldb
  ];

  programs.zathura = {
    enable = true;
    options = {
      dbus-service = true;
      filemonitor = "glib";
      selection-clipboard = "clipboard";
      statusbar-home-tilde = true;
      synctex = true;
      synctex-edit-modifier = "ctrl";
      window-title-basename = true;
      window-title-home-tilde = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    plugins = [ pkgs.vimPlugins.lazy-nvim ];
    initLua = ''
      require("config.lazy")
    '';
  };
}
