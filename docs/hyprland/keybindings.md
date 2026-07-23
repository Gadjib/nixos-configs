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
| `SUPER+B` | browser | `firefox` |
| `SUPER+V` | clipboard history | `cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy` |
| `Print` | screenshot area | `grim -g "$(slurp)" - | swappy -f -` |

## Layout/window

| Клавиши | Действие |
|---|---|
| `SUPER+F` | fullscreen |
| `SUPER+Space` | toggle floating |
| `SUPER+P` | pseudo |
| `SUPER+O` | toggle split |
| `SUPER+Left/Right/Up/Down` | focus window |
| `SUPER+H/J/K/L` | focus window vim-style |
| `SUPER+Shift+Left/Right/Up/Down` | move window |
| `SUPER+Shift+H/J/K/L` | move window vim-style |
| `SUPER+mouse left` | move window |
| `SUPER+mouse right` | resize window |

## Workspaces

| Клавиши | Действие |
|---|---|
| `SUPER+1..9` | workspace 1..9 |
| `SUPER+0` | workspace 10 |
| `SUPER+CTRL+1..9` | workspace 11..19 |
| `SUPER+CTRL+0` | workspace 20 |
| `SUPER+CTRL+Shift+1..9` | move active window to workspace 11..19 |
| `SUPER+CTRL+Shift+0` | move active window to workspace 20 |
| `SUPER+Shift+1..9` | move active window to workspace 1..9 |
| `SUPER+Shift+0` | move active window to workspace 10 |

## Volume/media/brightness

| Клавиша | Действие |
|---|---|
| `XF86AudioRaiseVolume` | `pamixer -i 5` + swayosd |
| `XF86AudioLowerVolume` | `pamixer -d 5` + swayosd |
| `XF86AudioMute` | toggle mute + swayosd |
| `XF86AudioPlay` | `playerctl play-pause` |
| `XF86AudioNext` | `playerctl next` |
| `XF86AudioPrev` | `playerctl previous` |
| `XF86MonBrightnessUp` | `brightnessctl set 5%+` + swayosd |
| `XF86MonBrightnessDown` | `brightnessctl set 5%-` + swayosd |

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
