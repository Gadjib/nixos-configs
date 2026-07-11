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

## LazyVim-ready dependencies

В системе есть базовый dev stack и Nerd Fonts. Не усложняйте Neovim до того, как появится конкретная задача.

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
