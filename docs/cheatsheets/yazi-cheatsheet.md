# Yazi cheatsheet

`~/.config/yazi` отсутствует, поэтому таблица основана на preset keybindings из локального `man yazi`. После добавления `keymap.toml` обновить.

| Действие | Клавиши |
|---|---|
| Запуск | `yazi`, `yazi .`, `yazi ~/Downloads` |
| Вверх/вниз | `j/k`, arrows |
| Parent/enter directory | `h/l` |
| Open | `o`, `Enter` |
| Select | `Space` |
| Select all | `Ctrl+a` |
| Invert selection | `Ctrl+r` |
| Visual select/unset | `v` / `V` |
| Copy/yank | `y` |
| Cut | `x` |
| Paste / overwrite | `p` / `P` |
| Rename | `r` |
| Trash / hard delete | `d` / `D` |
| Create file/dir | `a` |
| Symlink absolute/relative | `-` / `_` |
| Find forward/backward | `/` / `?` |
| Search via fd/rg | `s` / `S` |
| Filter | `f` |
| Hidden files | `.` |
| Copy path/name | `cc`, `cd`, `cf`, `cn` |
| New tab | `t` |
| Switch tab | `1..9`, `[`, `]` |
| Help | `?` VERIFY |
| Quit | `q` VERIFY |

Fallback-команды:

```bash
fd pattern | fzf
nvim "$(fd -e nix | fzf)"
trash-put file
7z x archive.zip
wl-copy < file
```
