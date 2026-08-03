local nix = require("config.nix")
local runner = require("config.runner")

return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  {
    "nvim-treesitter/nvim-treesitter",
    build = false,
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          cmd = {
            nix.tools.clangd,
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=none",
          },
          capabilities = { offsetEncoding = { "utf-16" } },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
        basedpyright = {
          cmd = { nix.tools.basedpyright, "--stdio" },
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "standard",
                autoImportCompletions = true,
                diagnosticSeverityOverrides = {
                  reportDuplicateImport = "none",
                  reportUnusedImport = "none",
                  reportUnusedVariable = "none",
                },
              },
            },
          },
        },
        ruff = {
          cmd = { nix.tools.ruff, "server" },
          init_options = { settings = { logLevel = "error" } },
        },
      },
      setup = {
        ruff = function()
          Snacks.util.lsp.on({ name = "ruff" }, function(_, client)
            client.server_capabilities.hoverProvider = false
          end)
        end,
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp-signature-help" },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "nvim_lsp_signature_help" })
      return opts
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_format = "never",
      },
      formatters_by_ft = {
        c = { "clang_format" },
        cpp = { "clang_format" },
        python = { "ruff_format" },
        tex = {},
        plaintex = {},
        bib = {},
      },
      formatters = {
        clang_format = { command = nix.tools.clang_format },
        ruff_format = { command = nix.tools.ruff },
      },
    },
  },
  {
    "Civitasv/cmake-tools.nvim",
    opts = {
      cmake_command = "cmake",
      ctest_command = "ctest",
      cmake_use_preset = true,
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
      cmake_compile_commands_options = {
        action = "soft_link",
        target = vim.uv.cwd,
      },
      cmake_dap_configuration = {
        name = "CMake target",
        type = "codelldb",
        request = "launch",
        stopOnEntry = false,
        runInTerminal = true,
      },
      cmake_executor = { name = "quickfix", opts = { auto_close_when_success = true } },
      cmake_runner = { name = "terminal", opts = { focus = true, start_insert = true } },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      local dap = require("dap")
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = nix.tools.codelldb,
          args = { "--port", "${port}" },
        },
      }
      return opts
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup(nix.tools.debugpy_adapter)
      for _, configuration in ipairs(require("dap").configurations.python or {}) do
        configuration.pythonPath = runner.python_executable
        configuration.console = "integratedTerminal"
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "orjangj/neotest-ctest",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = function()
            return { runner.python_executable() }
          end,
          dap = { justMyCode = false, console = "integratedTerminal" },
        },
        ["neotest-ctest"] = { dap_adapter = "codelldb" },
      },
    },
  },
  {
    "linux-cultist/venv-selector.nvim",
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        override_notify = false,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    init = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == "clangd" then
            vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
          end
        end,
      })
    end,
  },
}
