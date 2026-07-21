# Waybar

## Назначение

Waybar - верхняя панель Hyprland. Показывает workspaces, активное окно, часы, раскладку, power profile, CPU/RAM/temperature, tray, audio, battery и power menu.

## Где конфиг

Источник: `/home/ilya/nixos-config/home/ilya/waybar/waybar.nix`.

Runtime:

```bash
~/.config/waybar/config
~/.config/waybar/style.css
```

## Текущие модули

- Left: `hyprland/workspaces`, `hyprland/window`.
- Center: empty.
- Right: language, power profile, cpu, memory, temperature, tray, pulseaudio,
  battery, date (`dd.mm.yy`), custom power.

Workspace indicators use compact width and padding. The active-window pill is
hidden completely when the current workspace has no active window.

Отдельных network/bluetooth modules в Waybar нет. Сеть управляется через
`nm-applet` в tray; Bluetooth управляется через `blueman-applet` в tray. Оба
апплета запускаются user services с restart policy.

## Перезапуск

```bash
pkill waybar
waybar
```

Или из Hyprland:

```bash
hyprctl dispatch exec waybar
```

## Типичные изменения

Правьте `home/ilya/waybar/waybar.nix`, затем:

```bash
nh os test /home/ilya/nixos-config
pkill waybar
waybar
```

## Если bar не появился

```bash
command -v waybar
waybar
journalctl --user -b | rg -i "waybar|error"
hyprctl monitors
```

Частые причины: ошибка JSON/config, отсутствующий icon font, модуль обращается к отсутствующему сервису.

## Cheatsheet

```bash
bat home/ilya/waybar/waybar.nix
pkill waybar
waybar
journalctl --user -b | rg -i waybar
```
