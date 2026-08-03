local M = {}
local nix = require("config.nix")

local state = {
  job = nil,
  last = nil,
}

local function root(markers)
  return vim.fs.root(0, markers or { ".git" }) or vim.fn.getcwd()
end

local function project_kind()
  local project_root = root({ "CMakeLists.txt", "Makefile", "compile_commands.json", ".git" })
  if vim.fn.filereadable(project_root .. "/CMakeLists.txt") == 1 then
    return "cmake", project_root
  end
  if vim.fn.filereadable(project_root .. "/Makefile") == 1 then
    return "make", project_root
  end
  if vim.fn.filereadable(project_root .. "/compile_commands.json") == 1 then
    return "project", project_root
  end
  return "single", vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end

local function python_executable()
  if vim.env.VIRTUAL_ENV then
    local selected = vim.env.VIRTUAL_ENV .. "/bin/python"
    if vim.fn.executable(selected) == 1 then
      return selected
    end
  end
  local project_root = root({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" })
  for _, name in ipairs({ ".venv", "venv" }) do
    local candidate = project_root .. "/" .. name .. "/bin/python"
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nix.tools.python
end

local function shell_command(argv)
  return table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
end

local function open_terminal(command, cwd, remember, cleanup_path)
  if remember ~= false then
    state.last = { command = command, cwd = cwd }
  end
  vim.cmd("botright 14new")
  vim.bo.bufhidden = "wipe"
  state.job = vim.fn.termopen(command, {
    cwd = cwd,
    on_exit = function()
      state.job = nil
      if cleanup_path then
        vim.uv.fs_unlink(cleanup_path)
      end
    end,
  })
  vim.cmd("startinsert")
end

local function save_current()
  if vim.bo.modified then
    vim.cmd("silent update")
  end
end

local function output_path(file)
  local directory = vim.fn.stdpath("cache") .. "/runs/" .. vim.fn.sha256(file):sub(1, 12)
  vim.fn.mkdir(directory, "p")
  return directory .. "/" .. vim.fn.fnamemodify(file, ":t:r")
end

local function single_compile(file, output)
  local cpp = vim.bo.filetype == "cpp"
  local compiler = cpp and nix.tools.clangxx or nix.tools.clang
  local standard = cpp and "-std=c++20" or "-std=c17"
  return {
    compiler,
    standard,
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-g",
    "-O0",
    file,
    "-o",
    output,
  }
end

function M.build_current()
  save_current()
  local file = vim.api.nvim_buf_get_name(0)
  local kind, cwd = project_kind()
  if kind == "cmake" then
    vim.cmd("CMakeBuild")
  elseif kind == "make" then
    open_terminal("make", cwd)
  elseif vim.tbl_contains({ "c", "cpp" }, vim.bo.filetype) then
    local output = output_path(file)
    open_terminal(shell_command(single_compile(file, output)), cwd)
  else
    vim.notify("No build action for " .. vim.bo.filetype, vim.log.levels.WARN)
  end
end

local function run_current(args)
  save_current()
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype == "python" then
    local argv = { python_executable(), file }
    vim.list_extend(argv, args or {})
    open_terminal(shell_command(argv), root({ "pyproject.toml", "setup.py", ".git" }))
    return
  end
  if vim.tbl_contains({ "c", "cpp" }, vim.bo.filetype) then
    local kind, cwd = project_kind()
    if kind == "cmake" then
      vim.cmd("CMakeRun")
      return
    elseif kind ~= "single" then
      vim.notify("Use the project target or <leader>rp; single-file flags were not applied", vim.log.levels.WARN)
      return
    end
    local output = output_path(file)
    local command = shell_command(single_compile(file, output)) .. " && " .. shell_command(vim.list_extend({ output }, args or {}))
    open_terminal(command, cwd)
    return
  end
  vim.notify("Run Current supports C, C++ and Python", vim.log.levels.WARN)
end

function M.run_current()
  run_current({})
end

function M.run_current_with_args()
  local input = vim.fn.input("Arguments: ")
  run_current(input == "" and {} or require("dap.utils").splitstr(input))
end

function M.run_last()
  if not state.last then
    vim.notify("No previous run", vim.log.levels.WARN)
    return
  end
  open_terminal(state.last.command, state.last.cwd, false)
end

function M.stop()
  if state.job and vim.fn.jobwait({ state.job }, 0)[1] == -1 then
    vim.fn.jobstop(state.job)
  else
    vim.notify("No running terminal job", vim.log.levels.INFO)
  end
end

function M.run_project_command()
  local command = vim.fn.input("Project command: ")
  if command ~= "" then
    open_terminal(command, root({ "pyproject.toml", "CMakeLists.txt", "Makefile", ".git" }))
  end
end

function M.run_python_module()
  local module = vim.fn.input("Python module: ")
  if module ~= "" then
    open_terminal(shell_command({ python_executable(), "-m", module }), root({ "pyproject.toml", ".git" }))
  end
end

function M.run_python_selection()
  if vim.bo.filetype ~= "python" then
    vim.notify("Python selection requires a Python buffer", vim.log.levels.WARN)
    return
  end
  local first = vim.fn.line("v")
  local last = vim.fn.line(".")
  if first > last then
    first, last = last, first
  end
  local path = vim.fn.tempname() .. ".py"
  vim.fn.writefile(vim.api.nvim_buf_get_lines(0, first - 1, last, false), path)
  open_terminal(shell_command({ python_executable(), "-i", path }), root({ "pyproject.toml", ".git" }), true, path)
end

function M.debug_current()
  save_current()
  local dap = require("dap")
  local file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype == "python" then
    dap.run({
      type = "python",
      request = "launch",
      name = "Debug current Python file",
      program = file,
      cwd = root({ "pyproject.toml", ".git" }),
      pythonPath = python_executable,
      console = "integratedTerminal",
      args = function()
        return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
      end,
    })
    return
  end
  if vim.tbl_contains({ "c", "cpp" }, vim.bo.filetype) then
    local kind, cwd = project_kind()
    if kind == "cmake" then
      vim.cmd("CMakeDebug")
      return
    elseif kind ~= "single" then
      vim.notify("Select the project executable before debugging", vim.log.levels.WARN)
      return
    end
    local output = output_path(file)
    local result = vim.system(single_compile(file, output), { cwd = cwd, text = true }):wait()
    if result.code ~= 0 then
      vim.notify(result.stderr, vim.log.levels.ERROR)
      return
    end
    dap.run({
      type = "codelldb",
      request = "launch",
      name = "Debug current file",
      program = output,
      cwd = cwd,
      stopOnEntry = false,
      args = function()
        return require("dap.utils").splitstr(vim.fn.input("Arguments: "))
      end,
    })
  end
end

M.python_executable = python_executable

return M
