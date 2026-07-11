# Rofi

## Назначение

Rofi используется как app launcher, run menu, window switcher и clipboard menu через cliphist.

## Где конфиг

Источник: `/home/ilya/nixos-config/home/ilya/rofi/rofi.nix`.

Runtime:

```bash
~/.config/rofi/config.rasi
~/.config/rofi/theme.rasi
```

Настроены modi: `drun,run,window`, terminal `kitty`, icons `Papirus-Dark`.
History включен, `max-history-size = 100`, `sort = true`,
`sorting-method = fzf`, `matching = fuzzy`, `drun-use-desktop-cache = true`.
Это нужно, чтобы launcher учитывал часто/недавно запускаемые приложения и
поднимал их выше в списке.

## Команды

```bash
rofi -show drun
rofi -show run
rofi -show window
cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy
```

Hyprland bind:

```text
SUPER+D -> rofi -show drun
SUPER+V -> clipboard history
```

## Темы

Тема подключена из `home/ilya/rofi/theme.rasi`. Это Catppuccin Macchiato Blue
с заметной прозрачностью: `bg = #24273acc`, `surface = #363a4fd9`. Меняйте
исходник и применяйте rebuild. Для быстрой проверки запускайте
`rofi -show drun` из терминала, чтобы видеть ошибки.

## Частые ошибки

- Rofi запускается без иконок: проверьте `Papirus-Dark` и шрифты.
- Clipboard menu пустой: проверьте `cliphist list` и `wl-paste --watch` процессы.
- Run не запускает команду: проверьте PATH и shell.

## Troubleshooting

```bash
command -v rofi cliphist wl-copy
rofi -show drun
cliphist list
journalctl --user -b | rg -i "rofi|cliphist"
```

## Cheatsheet

```bash
SUPER+D
SUPER+V
rofi -show drun
rofi -show run
rofi -show window
```
