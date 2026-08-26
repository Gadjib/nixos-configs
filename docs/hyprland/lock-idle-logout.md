# Lock, idle, logout

## Назначение

Экран блокируется через `hyprlock`, idle-действия делает `hypridle`, logout/power menu показывает `wlogout`.

## Где конфиг

Источник: `/home/ilya/nixos-config/home/ilya/hypr/hyprland.nix`.

Runtime:

```bash
~/.config/hypr/hyprlock.conf
~/.config/hypr/hypridle.conf
```

## Текущие idle actions

`hypridle`:

- `lock_cmd = pidof hyprlock || hyprlock`;
- before sleep: `loginctl lock-session`;
- after sleep: `hyprctl dispatch dpms on`;
- через 300 секунд: `loginctl lock-session`;
- через 600 секунд: `hyprctl dispatch dpms off`;
- on resume: `hyprctl dispatch dpms on`.

## Заблокировать экран

```bash
loginctl lock-session
hyprlock
```

## Logout menu

```bash
wlogout
wlogout --protocol layer-shell
```

Hyprland bind:

```text
SUPER+M -> wlogout
```

Waybar power button вызывает `wlogout --protocol layer-shell`.

## Suspend / hibernate

```bash
systemctl suspend-then-hibernate
```

Пункт `Suspend → Hibernate` в Wlogout сначала переводит ноутбук в S3 `deep`,
а через 2 часа без обычного пробуждения — в hibernate. Перед любым sleep
hypridle вызывает lock. Автоматического suspend по idle нет; idle управляет
только lock и DPMS.

## Troubleshooting

```bash
command -v hyprlock hypridle wlogout
pgrep -a hypridle
journalctl --user -b | rg -i "hypridle|hyprlock|wlogout|loginctl"
loginctl session-status
```

## Cheatsheet

```bash
hyprlock
loginctl lock-session
wlogout
systemctl suspend-then-hibernate
pgrep -a hypridle
```
