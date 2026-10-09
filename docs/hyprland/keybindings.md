# Hyprland keybindings

## Назначение

Текущие бинды взяты из `/home/ilya/nixos-config/home/ilya/hypr/hyprland.nix`. Модификатор `$mod = SUPER`.

## Основные бинды

| Клавиши | Действие | Реальная команда |
|---|---|---|
| `SUPER+Enter` | terminal | `kitty` |
| `SUPER+D` | launcher | `rofi -show drun` |
| `SUPER+Q` | close active window | `killactive` |
| `SUPER+M` | logout menu | `wlogout` |
| `SUPER+E` | file manager | `dolphin` |
| `SUPER+B` | browser | `/home/ilya/.local/bin/firefox-hyprland` |
| `SUPER+V` | clipboard history | `cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy` |
| `Print` / `Shift+Print` | область / весь экран в буфер | общий screenshot handler |
| `Ctrl+Print` / `Ctrl+Shift+Print` | область / весь экран в Swappy | общий screenshot handler |

## Layout/window

| Клавиши | Действие |
|---|---|
| `SUPER+F` | fullscreen |
| `SUPER+Shift+F` | maximize с сохранением панели и рабочей области |
| `SUPER+Space` | toggle floating |
| `SUPER+P` | pseudo |
| `SUPER+O` | toggle split |
| `SUPER+C` | центрировать floating-окно |
| `SUPER+X` | закрепить floating-окно на всех workspace |
| `SUPER+Tab` / `SUPER+Shift+Tab` | следующее / предыдущее окно по истории |
| `SUPER+Left/Right/Up/Down` | focus window |
| `SUPER+H/J/K/L` | focus window vim-style |
| `SUPER+Shift+Left/Right/Up/Down` | move window |
| `SUPER+Shift+H/J/K/L` | move window vim-style |
| `SUPER+Ctrl+Left/Right/Up/Down` | resize window с клавиатуры |
| `SUPER+Ctrl+H/J/K/L` | resize window vim-style |
| `SUPER+mouse left` | move window |
| `SUPER+mouse right` | resize window |

## Workspaces

| Клавиши | Действие |
|---|---|
| `SUPER+1..9` | workspace 1..9 |
| `SUPER+0` | workspace 10 |
| `SUPER+CTRL+1..9` | workspace 11..19 |
| `SUPER+CTRL+0` | workspace 20 |
| `SUPER+[` / `SUPER+]` | предыдущий / следующий существующий workspace |
| ``SUPER+` `` | вернуться на предыдущий workspace |
| `SUPER+колесо вверх/вниз` | предыдущий / следующий существующий workspace |
| `SUPER+CTRL+Shift+1..9` | отправить окно на workspace 11..19, не переходя туда |
| `SUPER+CTRL+Shift+0` | отправить окно на workspace 20, не переходя туда |
| `SUPER+Shift+1..9` | отправить окно на workspace 1..9, не переходя туда |
| `SUPER+Shift+0` | отправить окно на workspace 10, не переходя туда |
| `SUPER+S` | показать/скрыть special workspace `magic` |
| `SUPER+Shift+S` | переместить окно в `magic` |

## Touchpad gestures

| Жест | Действие |
|---|---|
| 3 или 4 пальца горизонтально | переключить workspace |
| 4 пальца вниз | показать/скрыть special workspace `magic` |
| 4 пальца вверх | fullscreen |
| pinch-in 3 пальцами | перевести окно в floating |
| pinch-out / pinch-in 4 пальцами | cursor zoom 2x / 1x |

## Volume/media/brightness

| Клавиша | Действие |
|---|---|
| `XF86AudioRaiseVolume` | увеличить громкость через `swayosd-client` |
| `XF86AudioLowerVolume` | уменьшить громкость через `swayosd-client` |
| `XF86AudioMute` | toggle mute через `swayosd-client` |
| `XF86AudioPlay` | `playerctl play-pause` |
| `XF86AudioNext` | `playerctl next` |
| `XF86AudioPrev` | `playerctl previous` |
| `XF86MonBrightnessUp` | увеличить яркость через `swayosd-client` |
| `XF86MonBrightnessDown` | уменьшить яркость через `swayosd-client` |

## Проверить реальные бинды

```bash
bat /home/ilya/nixos-config/home/ilya/hypr/hyprland.nix
rg '"\\$mod|XF86|Print' /home/ilya/nixos-config/home/ilya/hypr/hyprland.nix
hyprctl binds
```

## Частые ошибки

- Конфликт с приложением, которое перехватывает `SUPER`.
- Бинд изменен в Nix, но rebuild/reload не выполнен.
- Команда в bind отсутствует в PATH.

## Troubleshooting

```bash
command -v kitty rofi dolphin firefox wlogout grim slurp swappy
hyprctl binds
hyprctl reload
journalctl --user -b | rg -i "hypr|bind|error"
```

## Cheatsheet

```text
SUPER+Enter terminal
SUPER+D launcher
SUPER+Q close
SUPER+M logout
SUPER+E dolphin
SUPER+B firefox
SUPER+V clipboard
Print screenshot area
SUPER+1..0 workspaces
SUPER+CTRL+1..0 workspaces 11..20
SUPER+CTRL+Shift+1..0 move to workspace 11..20
SUPER+Shift+1..0 move to workspace
```
