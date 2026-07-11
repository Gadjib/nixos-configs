# Hyprland

## Назначение

Hyprland - основная Wayland-сессия. KDE Plasma 6 остается fallback-сессией через SDDM.

## Когда пользоваться

Читайте этот раздел при настройке hotkeys, мониторов, waybar, rofi, kitty, уведомлений, screenshots, lock/idle/logout и проблемах входа.

## Где конфиг

- Основной Hyprland Home Manager config: `/home/ilya/nixos-config/home/ilya/hypr/hyprland.nix`.
- Сгенерированный runtime config: `~/.config/hypr/hyprland.conf`.
- Hyprlock: `~/.config/hypr/hyprlock.conf`, источник в том же `hyprland.nix`.
- Hypridle: `~/.config/hypr/hypridle.conf`.

Правьте источник в репозитории, а не generated файлы.

## Компоненты

- `waybar` стартует через `exec-once`.
- `mako` стартует через `exec-once`.
- `awww-daemon` стартует для wallpaper, затем `awww img` применяет
  `/home/ilya/nixos-config/assets/wallpapers/wallhaven-2eqpzm.png`.
- `hypridle` управляет idle lock и DPMS.
- `wlogout` вызывается по `SUPER+M`.
- `rofi -show drun` вызывается по `SUPER+D`.
- `grim`, `slurp`, `swappy` делают area screenshot по `Print`.
- `cliphist` хранит clipboard history.

## Как выбрать сессию

На SDDM выберите Hyprland или Plasma. Если Hyprland сломан, входите в Plasma и исправляйте конфиг.

## Безопасное изменение

```bash
cd /home/ilya/nixos-config
nvim home/ilya/hypr/hyprland.nix
git diff
nh os test /home/ilya/nixos-config
hyprctl reload
```

Если сессия сломалась, используйте KDE или TTY.

## Troubleshooting

```bash
hyprctl monitors
hyprctl clients
hyprctl reload
journalctl --user -b
systemctl --user status xdg-desktop-portal-hyprland
```

## Cheatsheet

```bash
SUPER+Enter  # kitty
SUPER+D      # rofi drun
SUPER+M      # wlogout
Print        # area screenshot to swappy
hyprctl reload
hyprctl monitors
```
