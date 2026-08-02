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

Конфиг: `/home/ilya/nixos-config/home/ilya/nvim/nvim.nix`.

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
русской/английской орфографии. Стрелки `Up`/`Down` перемещаются по видимым
частям перенесённой строки; `k`/`j` по-прежнему двигаются по строкам файла.

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
