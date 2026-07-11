# Mako notifications

## Назначение

Mako показывает Wayland-уведомления. Стартует через Hyprland `exec-once`.

## Где конфиг

Источник: `/home/ilya/nixos-config/home/ilya/mako/mako.nix`.

Runtime:

```bash
~/.config/mako/config
```

## Текущая настройка

- Font: `Inter 10`.
- Background: `#24273acc`.
- Text: `#cad3f5ff`.
- Border: `#8aadf4ff`, size 2, radius 8.
- Padding 10, margin 8.
- Default timeout 5000 ms.

## Проверка

```bash
notify-send "Test" "Mako notification"
```

Если `notify-send` отсутствует, проверьте наличие пакета libnotify или используйте уведомления приложений.

## Перезапуск

```bash
pkill mako
mako
```

## Настройка timeout

Правьте `default-timeout` в `home/ilya/mako/mako.nix`, затем:

```bash
nh os test /home/ilya/nixos-config
pkill mako
mako
```

## Troubleshooting

```bash
command -v mako notify-send
mako
journalctl --user -b | rg -i "mako|notification|portal"
```

Если уведомления не приходят, проверьте, не запущен ли другой notification daemon.

## Cheatsheet

```bash
notify-send "Test" "Hello"
pkill mako
mako
bat home/ilya/mako/mako.nix
```
