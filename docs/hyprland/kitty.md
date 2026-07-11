# Kitty

## Назначение

Kitty - основной терминал. В Hyprland он открывается `SUPER+Enter`.

## Где конфиг

Источник: `/home/ilya/nixos-config/home/ilya/kitty/kitty.nix`.

Runtime:

```bash
~/.config/kitty/kitty.conf
```

## Текущая настройка

- Font: `JetBrainsMono Nerd Font`, size 11.
- Scrollback: 10000 lines.
- `copy_on_select = clipboard`.
- Audio bell выключен.
- Background opacity `0.82`.
- Цвета в стиле Catppuccin Macchiato Blue.
- Keybindings: `Ctrl+Shift+C`, `Ctrl+Shift+V`.

## Базовое использование

```bash
kitty
```

Copy/paste:

- выделить мышью - копирует в clipboard;
- `Ctrl+Shift+C` - copy;
- `Ctrl+Shift+V` - paste.

Tabs/windows/splits: VERIFY - в текущем `kitty.nix` пользовательские бинды для tabs/splits не заданы; проверьте дефолты через `kitty --help` и `man kitty`.

## Fonts/icons

Если символы Waybar/Yazi выглядят квадратиками, проверьте Nerd Font:

```bash
fc-match "JetBrainsMono Nerd Font"
```

## Troubleshooting

```bash
command -v kitty
kitty --debug-config
bat ~/.config/kitty/kitty.conf
journalctl --user -b | rg -i kitty
```

## Cheatsheet

```text
SUPER+Enter     открыть kitty
Ctrl+Shift+C    copy
Ctrl+Shift+V    paste
выделение мышью copy_on_select
```
