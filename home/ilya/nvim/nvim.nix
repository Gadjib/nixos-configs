{ pkgs, ... }:

let
  russianSpell = pkgs.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.spl";
    hash = "sha256-6y0714ogILMLzAp8/r2s6/t6QnWBEU9muIpXeubaxU0=";
  };
  russianSuggestions = pkgs.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.sug";
    hash = "sha256-6r2GForYXVv7gGiAjPeYK6sDdK/CmctJ7MidcWFvOTs=";
  };
in
{
  xdg.configFile = {
    "nvim/spell/ru.utf-8.spl".source = russianSpell;
    "nvim/spell/ru.utf-8.sug".source = russianSuggestions;
  };

  home.packages = with pkgs; [
    texlab
    ltex-ls-plus
    neovim-remote
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

    plugins = with pkgs.vimPlugins; [
      vimtex
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-vimtex
      cmp_luasnip
      luasnip
      (nvim-treesitter.withPlugins (parsers: [
        parsers.latex
        parsers.bibtex
      ]))
    ];

    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.termguicolors = true
      vim.opt.signcolumn = "yes"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      vim.g.mapleader = " "
      vim.g.maplocalleader = "\\"

      -- VimTeX owns the only continuous latexmk process. TexLab builds are off.
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.g.vimtex_view_method = "zathura_simple"
      vim.g.vimtex_view_automatic = 1
      vim.g.vimtex_view_forward_search_on_start = 1
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        cites = 1,
        fancy = 1,
        greek = 1,
        ligatures = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }

      vim.diagnostic.config({
        severity_sort = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        virtual_text = {
          source = "if_many",
          spacing = 2,
        },
        float = {
          border = "rounded",
          source = true,
        },
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function latex_root_dir(bufnr, on_dir)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local file_dir = vim.fs.dirname(filename)
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)

        for _, line in ipairs(lines) do
          local main = line:lower():match(
            "^%%%s*!?%s*tex%s+root%s*[:=]%s*(.-)%s*$"
          )
          if main and main ~= "" then
            local main_path = vim.fs.normalize(vim.fs.joinpath(file_dir, main))
            on_dir(vim.fs.dirname(main_path))
            return
          end
        end

        local root = vim.fs.root(bufnr, {
          ".texlabroot",
          "texlabroot",
          ".latexmkrc",
          "latexmkrc",
          ".git",
        })
        if root then
          on_dir(root)
          return
        end

        local main = vim.fs.find("main.tex", {
          path = file_dir,
          upward = true,
          type = "file",
        })[1]
        on_dir(main and vim.fs.dirname(main) or file_dir)
      end

      vim.lsp.config("texlab", {
        cmd = { "${pkgs.texlab}/bin/texlab" },
        capabilities = capabilities,
        root_dir = latex_root_dir,
        settings = {
          texlab = {
            build = {
              onSave = false,
              forwardSearchAfter = false,
            },
            chktex = {
              onOpenAndSave = true,
              onEdit = true,
            },
            completion = {
              matcher = "fuzzy-ignore-case",
            },
            diagnosticsDelay = 300,
          },
        },
      })

      vim.lsp.config("ltex_plus", {
        cmd = { "${pkgs.ltex-ls-plus}/bin/ltex-ls-plus" },
        capabilities = capabilities,
        root_dir = latex_root_dir,
        settings = {
          ltex = {
            enabled = { "latex", "bibtex" },
            language = "auto",
          },
        },
      })

      vim.lsp.enable({ "texlab", "ltex_plus" })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if vim.fn.maparg("gd", "n") == "" then
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
              buffer = args.buf,
              desc = "LSP: go to definition",
            })
          end
        end,
      })

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      luasnip.config.setup({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.filetype({ "tex", "plaintex" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vimtex" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })

      cmp.setup.filetype("bib", {
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })

      local snippet = luasnip.snippet
      local insert = luasnip.insert_node
      local rep = require("luasnip.extras").rep
      local fmta = require("luasnip.extras.fmt").fmta

      luasnip.add_snippets("tex", {
        snippet("beg", fmta([[
          \begin{<>}
            <>
          \end{<>}
        ]], { insert(1, "environment"), insert(0), rep(1) })),
        snippet("frac", fmta([[\frac{<>}{<>}]], {
          insert(1, "numerator"), insert(2, "denominator"),
        })),
        snippet("mk", fmta([[$<>$]], { insert(1) })),
        snippet("eq", fmta([[
          \begin{equation}
            \label{eq:<>}
            <>
          \end{equation}
        ]], { insert(1, "label"), insert(0) })),
        snippet("fig", fmta([[
          \begin{figure}[htbp]
            \centering
            \includegraphics[width=0.8\textwidth]{<>}
            \caption{<>}
            \label{fig:<>}
          \end{figure}
        ]], { insert(1, "path"), insert(2, "caption"), insert(3, "label") })),
        snippet("sec", fmta([[
          \section{<>}
          \label{sec:<>}
        ]], { insert(1, "title"), insert(2, "label") })),
        snippet("cite", fmta([[\cite{<>}]], { insert(1) })),
        snippet("ref", fmta([[\ref{<>}]], { insert(1) })),
        snippet("item", fmta([[
          \begin{itemize}
            \item <>
          \end{itemize}
        ]], { insert(0) })),
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "plaintex" },
        callback = function(args)
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.breakindent = true
          vim.opt_local.textwidth = 0
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = "nc"
          vim.opt_local.spell = true
          vim.opt_local.spelllang = { "en_us", "ru" }

          vim.keymap.set({ "n", "x" }, "<Down>", "gj", {
            buffer = args.buf,
            desc = "Move down by display line",
          })
          vim.keymap.set({ "n", "x" }, "<Up>", "gk", {
            buffer = args.buf,
            desc = "Move up by display line",
          })
          vim.keymap.set("i", "<Down>", "<C-o>gj", {
            buffer = args.buf,
            desc = "Move down by display line",
          })
          vim.keymap.set("i", "<Up>", "<C-o>gk", {
            buffer = args.buf,
            desc = "Move up by display line",
          })
        end,
      })

      -- Keep VimTeX syntax active for TeX; it powers conceal and text objects.
      -- The LaTeX parser is installed, while BibTeX uses Treesitter highlighting.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "bib",
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    '';
  };
}
