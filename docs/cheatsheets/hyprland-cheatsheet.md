# Hyprland cheatsheet

## Hotkeys

| Клавиши | Действие |
|---|---|
| `SUPER+Enter` | kitty |
| `SUPER+D` | rofi drun |
| `SUPER+Q` | close active |
| `SUPER+M` | wlogout |
| `SUPER+E` | dolphin |
| `SUPER+B` | firefox |
| `SUPER+V` | cliphist rofi menu |
| `Print` | area screenshot to clipboard |
| `SUPER+F` | fullscreen |
| `SUPER+Shift+F` | maximize with Waybar visible |
| `SUPER+Space` | floating |
| `SUPER+C` | center floating window |
| `SUPER+X` | pin floating window |
| `SUPER+Tab` / `SUPER+Shift+Tab` | next / previous recent window |
| `SUPER+H/J/K/L` | focus |
| `SUPER+Shift+H/J/K/L` | move window |
| `SUPER+Ctrl+H/J/K/L` | resize window |
| `SUPER+[` / `SUPER+]` | previous / next existing workspace |
| ``SUPER+` `` | previous workspace |
| `SUPER+mouse wheel` | previous / next existing workspace |
| `SUPER+1..0` | workspace 1..10 |
| `SUPER+CTRL+1..0` | workspace 11..20 |
| `SUPER+CTRL+Shift+1..0` | send to workspace 11..20 silently |
| `SUPER+Shift+1..0` | send to workspace 1..10 silently |
| `SUPER+S` | toggle special workspace `magic` |
| `SUPER+Shift+S` | move window to `magic` |

## Waybar/Mako

```bash
pkill waybar; waybar
pkill mako; mako
notify-send "Test" "Hello"
```

## Screenshots

```bash
grim ~/Pictures/screenshot.png
grim -g "$(slurp)" ~/Pictures/area.png
grim -g "$(slurp)" - | wl-copy
grim -g "$(slurp)" - | swappy -f -
```

## Clipboard

```bash
wl-copy < file
wl-paste
cliphist list
cliphist list | rofi -dmenu | cliphist decode | wl-copy
cliphist wipe
```

## Diagnostics

```bash
hyprctl monitors
hyprctl binds
hyprctl reload
journalctl --user -b | rg -i hypr
```
