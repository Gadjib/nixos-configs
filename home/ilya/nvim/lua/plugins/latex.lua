local nix = require("config.nix")

local function latex_root_dir(bufnr, on_dir)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local file_dir = vim.fs.dirname(filename)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 20, false)

  for _, line in ipairs(lines) do
    local main = line:lower():match("^%%%s*!?%s*tex%s+root%s*[:=]%s*(.-)%s*$")
    if main and main ~= "" then
      local main_path = vim.fs.normalize(vim.fs.joinpath(file_dir, main))
      on_dir(vim.fs.dirname(main_path))
      return
    end
  end

  local project_root = vim.fs.root(bufnr, {
    ".texlabroot",
    "texlabroot",
    ".latexmkrc",
    "latexmkrc",
    ".git",
  })
  if project_root then
    on_dir(project_root)
    return
  end

  local main = vim.fs.find("main.tex", { path = file_dir, upward = true, type = "file" })[1]
  on_dir(main and vim.fs.dirname(main) or file_dir)
end

return {
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
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
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        texlab = {
          cmd = { nix.tools.texlab },
          root_dir = latex_root_dir,
          settings = {
            texlab = {
              build = { onSave = false, forwardSearchAfter = false },
              chktex = { onOpenAndSave = true, onEdit = true },
              completion = { matcher = "fuzzy-ignore-case" },
              diagnosticsDelay = 300,
            },
          },
        },
        ltex_plus = {
          cmd = { nix.tools.ltex },
          root_dir = latex_root_dir,
          filetypes = { "bib", "plaintex", "tex" },
          settings = {
            ltex = {
              enabled = { "latex", "bibtex" },
              language = "auto",
            },
          },
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-vimtex" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "vimtex" })
      return opts
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      local luasnip = require("luasnip")
      luasnip.setup(opts)
      local snippet = luasnip.snippet
      local insert = luasnip.insert_node
      local rep = require("luasnip.extras").rep
      local fmta = require("luasnip.extras.fmt").fmta

      luasnip.add_snippets("tex", {
        snippet("beg", fmta("\\begin{<>}\n  <>\n\\end{<>}", { insert(1, "environment"), insert(0), rep(1) })),
        snippet("frac", fmta("\\frac{<>}{<>}", { insert(1, "numerator"), insert(2, "denominator") })),
        snippet("mk", fmta("$<>$", { insert(1) })),
        snippet("eq", fmta("\\begin{equation}\n  \\label{eq:<>}\n  <>\n\\end{equation}", { insert(1, "label"), insert(0) })),
        snippet("fig", fmta("\\begin{figure}[htbp]\n  \\centering\n  \\includegraphics[width=0.8\\textwidth]{<>}\n  \\caption{<>}\n  \\label{fig:<>}\n\\end{figure}", { insert(1, "path"), insert(2, "caption"), insert(3, "label") })),
        snippet("sec", fmta("\\section{<>}\n\\label{sec:<>}", { insert(1, "title"), insert(2, "label") })),
        snippet("cite", fmta("\\cite{<>}", { insert(1) })),
        snippet("ref", fmta("\\ref{<>}", { insert(1) })),
        snippet("item", fmta("\\begin{itemize}\n  \\item <>\n\\end{itemize}", { insert(0) })),
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      local disabled = type(opts.highlight.disable) == "table" and opts.highlight.disable or {}
      if not vim.tbl_contains(disabled, "latex") then
        table.insert(disabled, "latex")
      end
      opts.highlight.disable = disabled
    end,
  },
  {
    "LazyVim/LazyVim",
    init = function()
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
          vim.keymap.set({ "n", "x" }, "<Down>", "gj", { buffer = args.buf, desc = "Move down by display line" })
          vim.keymap.set({ "n", "x" }, "<Up>", "gk", { buffer = args.buf, desc = "Move up by display line" })
          vim.keymap.set("i", "<Down>", "<C-o>gj", { buffer = args.buf, desc = "Move down by display line" })
          vim.keymap.set("i", "<Up>", "<C-o>gk", { buffer = args.buf, desc = "Move up by display line" })
        end,
      })
    end,
  },
}
