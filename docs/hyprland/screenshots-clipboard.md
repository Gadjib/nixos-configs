# Screenshots и clipboard

## Назначение

Скриншоты и clipboard в Wayland делаются отдельными утилитами: `grim`, `slurp`, `swappy`, `wl-copy`, `wl-paste`, `cliphist`.

## Текущий bind

```text
Print -> grim -g "$(slurp)" - | swappy -f -
```

То есть `Print` выбирает область через `slurp`, делает screenshot через `grim` и открывает результат в `swappy`.

## Screenshot whole screen

```bash
grim ~/Pictures/screenshot.png
```

## Screenshot area

```bash
grim -g "$(slurp)" ~/Pictures/area.png
```

## Screenshot to clipboard

```bash
grim -g "$(slurp)" - | wl-copy
```

## Screenshot edit in swappy

```bash
grim -g "$(slurp)" - | swappy -f -
```

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
