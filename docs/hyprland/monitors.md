# Мониторы в Hyprland

## Назначение

Настройка экранов, scale, position, laptop + external monitor и emergency recovery при черном экране.

## Текущая настройка

В `home/ilya/hypr/hyprland.nix`:

```nix
monitor = [
  ",preferred,auto,1"
];
```

Это означает: для любого монитора использовать preferred mode, auto position, scale 1.

## Посмотреть мониторы

```bash
hyprctl monitors
hyprctl monitors all
```

Ищите имя вроде `eDP-1`, `HDMI-A-1`, `DP-1`, resolution, refresh, scale.

## Примеры конфигурации

Один монитор:

```nix
"eDP-1,preferred,auto,1"
```

Ноутбук + внешний справа:

```nix
"eDP-1,1920x1080@60,0x0,1"
"HDMI-A-1,2560x1440@60,1920x0,1"
```

Scale:

```nix
"eDP-1,preferred,auto,1"
```

Mirror обычно делается одинаковой позицией, но в Hyprland это менее удобно, чем extend. Для презентаций проверьте текущую версию `hyprctl keyword monitor ...`.

## Временно поправить

```bash
hyprctl keyword monitor ",preferred,auto,1"
hyprctl keyword monitor "eDP-1,preferred,0x0,1"
```

Из TTY правьте `home/ilya/hypr/hyprland.nix`, затем rebuild/test или откатитесь на старую generation.

## Черный экран

1. Подождите 10 секунд.
2. Перейдите в TTY `Ctrl+Alt+F2`.
3. Проверьте логи:

```bash
journalctl --user -b | rg -i "hypr|monitor|drm"
```

4. Верните monitor rule на `",preferred,auto,1"`.
5. Войдите в KDE fallback.

## Cheatsheet

```bash
hyprctl monitors
hyprctl keyword monitor ",preferred,auto,1"
nvim /home/ilya/nixos-config/home/ilya/hypr/hyprland.nix
nh os test /home/ilya/nixos-config
```
