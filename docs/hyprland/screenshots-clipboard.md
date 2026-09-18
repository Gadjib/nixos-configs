# Screenshots и clipboard

## Назначение

Скриншоты и clipboard в Wayland делаются отдельными утилитами: `grim`, `slurp`, `swappy`, `wl-copy`, `wl-paste`, `cliphist`.

## Сочетания клавиш

Все четыре сочетания используют `home/ilya/hypr/screenshot.sh`:

| Сочетание | Действие |
|---|---|
| `Print` | Область в буфер |
| `Shift+Print` | Весь экран в буфер |
| `Ctrl+Print` | Область в Swappy |
| `Ctrl+Shift+Print` | Весь экран в Swappy |

Повторные вызовы игнорируются во время выделения, захвата и редактирования
в Swappy. Закрой редактор перед следующим снимком. Escape и ошибка захвата
не меняют буфер обмена. Временный PNG удаляется при завершении обработчика.

## Clipboard

```bash
wl-copy < file.txt
wl-paste
wl-paste > pasted.txt
```

Clipboard history:

```bash
cliphist list
cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy
cliphist wipe
```

Hyprland autostart:

```text
wl-paste --type text --watch cliphist store
wl-paste --type image --watch cliphist store
```

## Частые ошибки

- `slurp` не выбирает область: проверьте, что вы в Wayland/Hyprland.
- Clipboard history пустой после login: новые элементы появятся после копирования.
- Не сохраняется файл: проверьте директорию `~/Pictures`.

## Troubleshooting

```bash
command -v grim slurp swappy wl-copy wl-paste cliphist
pgrep -a wl-paste
cliphist list
journalctl --user -b | rg -i "wl-paste|cliphist|grim|swappy"
```

## Cheatsheet

```bash
Print
grim ~/Pictures/screenshot.png
grim -g "$(slurp)" ~/Pictures/area.png
grim -g "$(slurp)" - | wl-copy
cliphist list | rofi -dmenu | cliphist decode | wl-copy
cliphist wipe
```
