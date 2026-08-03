# Neovim/Vim

## Назначение

Минимальный survival guide для редактирования Nix/Markdown/config files в терминале.

## Vim basics

Modes:

- normal - навигация и команды;
- insert - ввод текста (`i`);
- visual - выбор (`v`);
- command - команды после `:`.

Сохранить/выйти:

```vim
:w
:q
:wq
:q!
```

Поиск:

```vim
/text
n
N
```

Копировать/удалить/вставить:

```vim
yy
dd
p
u
Ctrl+r
```

Номера строк:

```vim
:set number
```

## Neovim

Используется LazyVim. Nix декларативно предоставляет сам LazyVim, плагины,
Treesitter parsers, LSP, formatters и debugger adapters; Mason ничего не
скачивает. Тема Neovim следует общей системной Catppuccin-теме из
`home/ilya/appearance.nix`.

Конфиг: `/home/ilya/nixos-config/home/ilya/nvim/nvim.nix` и Lua-файлы в
`home/ilya/nvim/lua/`.

Открыть:

```bash
nvim file.nix
nvim docs/index.md
nvim /home/ilya/nixos-config
```

Useful:

```vim
:e path
:split path
:vsplit path
:terminal
:checkhealth
```

## Редактирование Nix files

```bash
cd /home/ilya/nixos-config
nvim home/ilya/hypr/hyprland.nix
git diff
nh os test /home/ilya/nixos-config
```

## LaTeX

Открыть главный или подключаемый файл проекта:

```bash
nvim main.tex
nvim sections/chapter.tex
```

В начале подключаемого файла можно явно указать главный документ:

```tex
%! TEX root = ../main.tex
```

Сборкой владеет VimTeX; TexLab не запускает второй `latexmk`. Стандартный
`localleader` равен `\`, поэтому доступны штатные команды VimTeX:

| Клавиши | Действие |
|---|---|
| `\ll` | запустить или переключить непрерывную сборку |
| `\lk` | остановить сборку |
| `\lv` | открыть PDF или выполнить forward search |
| `\le` | показать ошибки компиляции |
| `\lo` | открыть полный вывод компилятора |
| `\li` | показать состояние и параметры проекта |
| `\lc` | удалить вспомогательные файлы |
| `\lC` | полная очистка, включая PDF |

В Zathura `Ctrl+левая кнопка мыши` выполняет inverse search в уже запущенный
Neovim. PDF автоматически обновляется после пересборки.

TexLab и LTeX+ показывают diagnostics и предоставляют completion, переходы к
определениям, ссылкам, меткам и подключаемым файлам. Стандартные LSP mappings
Neovim сохранены; `gd` переходит к определению, `grr` показывает ссылки,
`K` открывает документацию. Completion вызывается через `Ctrl+Space`, `Tab` и
`Shift+Tab` перемещают выбор или поля snippet, `Enter` подтверждает выбранный
пункт.

Доступны snippets `beg`, `frac`, `mk`, `eq`, `fig`, `sec`, `cite`, `ref` и
`item`. Для `.tex` включены мягкий перенос по словам, conceal и проверка
русской/английской орфографии. Стрелки `Up`/`Down` в normal, visual и insert
mode перемещаются по видимым частям перенесённой строки; `k`/`j` по-прежнему
двигаются по строкам файла.

## C, C++ и Python

Общие LSP-действия LazyVim:

| Клавиши | Действие |
|---|---|
| `gd` / `gD` | definition / declaration |
| `grr` | references |
| `K` / `gK` | hover / signature help |
| `<leader>ca` | code action |
| `<leader>cr` | rename по проекту |
| `<leader>cf` | format текущего файла или selection |
| `<leader>cd` | diagnostics текущей строки |
| `[d` / `]d` | предыдущая / следующая diagnostic |

Запуск и проекты:

| Клавиши | Действие |
|---|---|
| `<leader>rr` | запустить текущий C/C++/Python-файл |
| `<leader>ra` | запустить текущий файл с аргументами |
| `<leader>rR` / `<leader>rs` | повторить / остановить запуск |
| `<leader>rp` | выполнить введённую project command в terminal |
| `<leader>rm` | запустить Python module (`python -m`) |
| visual `<leader>rx` | выполнить выделенный Python-код в REPL |
| `<leader>cb` / `<leader>df` | собрать / отладить текущий файл или проект |
| `<leader>ch` | C/C++: переключить source/header |
| `<leader>cv` | Python: выбрать virtual environment |
| `<leader>mc` / `<leader>mb` | CMake configure / build |
| `<leader>mr` / `<leader>md` | CMake run / debug target |
| `<leader>mt` | выбрать CMake launch target |
| `<leader>mp` / `<leader>my` | выбрать preset / Debug или Release |

Для одиночного файла автоматически используются C17 или C++20, warnings и
debug symbols. Если найден `CMakeLists.txt`, `Makefile` или
`compile_commands.json`, используются настройки проекта, а одиночные flags не
добавляются. Запуск идёт в полноценном terminal buffer, поэтому работают stdin
и Python `input()`.

Тесты через Neotest:

| Клавиши | Действие |
|---|---|
| `<leader>tr` | ближайший тест |
| `<leader>tt` / `<leader>tT` | тесты файла / все тесты проекта |
| `<leader>tl` | повторить последний тест |
| `<leader>td` | отладить ближайший тест |
| `<leader>ts` | дерево тестов и результаты |
| `<leader>to` / `<leader>tO` | output теста / output panel |
| `<leader>tS` | остановить тест |

Отладка через DAP:

| Клавиши | Действие |
|---|---|
| `<leader>db` / `<leader>dB` | breakpoint / conditional breakpoint |
| `<leader>dL` / `<leader>dR` | log point / restart текущей session |
| `<leader>dc` / `<leader>da` | run/continue / run с аргументами |
| `<leader>dO` / `<leader>di` / `<leader>do` | step over / into / out |
| `<leader>dl` / `<leader>dt` | повторить последнюю debug-конфигурацию / terminate |
| `<leader>dr` / `<leader>du` | REPL / DAP UI |
| `<leader>de` / `<leader>dw` | evaluate / variables widget |

DAP UI содержит variables, watches, call stack, breakpoints и REPL. Он
открывается при старте отладки и закрывается при завершении.

## Emergency editing

Если Neovim сломан:

```bash
vim file
nano file
```

Минимум Vim: `i` ввод, `Esc`, `:wq` сохранить, `:q!` выйти без сохранения.

## Troubleshooting

```bash
command -v nvim vim nano
nvim --version
nvim --clean file
```

## Cheatsheet

```text
i insert
Esc normal
:w save
:q quit
:wq save quit
:q! quit no save
/text search
n next
dd delete line
u undo
```
