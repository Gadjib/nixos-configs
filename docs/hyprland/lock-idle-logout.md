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

`hypridle` запускается пользовательским `hypridle.service`, привязанным к
`hyprland-session.target`. При завершении процесса systemd перезапускает его
через 10 секунд; при выходе из Hyprland сервис останавливается.

После первого применения перехода с `exec-once` нужно выйти и снова войти
в Hyprland, чтобы завершить старый процесс и оставить запуск под systemd.

Настройки:

- `lock_cmd = pidof hyprlock || hyprlock`;
- before sleep: `loginctl lock-session`;
- after sleep: `hyprctl dispatch dpms on`;
- через 300 секунд: `loginctl lock-session`;
- через 600 секунд: `hyprctl dispatch dpms off`;
- on resume: `hyprctl dispatch dpms on`.

При подключённом HDMI автоматические lock и DPMS пропускаются. Полноэкранные
окна подавляют idle-таймеры. Ручная блокировка и блокировка перед сном
сохраняются независимо от этих исключений.

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

Hypridle получает уведомления о сне непосредственно от logind. Режим
`inhibit_sleep = 2` автоматически выбирает ожидание подтверждения блокировки
от композитора для этой конфигурации с hyprlock. Ожидание ограничено таймаутом
logind. Отдельный пользовательский `sleep.target` для этого не используется.

## Troubleshooting

```bash
systemctl --user status hypridle.service
journalctl --user -b -u hypridle.service
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
