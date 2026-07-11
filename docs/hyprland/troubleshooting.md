# Hyprland troubleshooting

## Hyprland не стартует

1. Выберите KDE Plasma в SDDM.
2. Или TTY: `Ctrl+Alt+F2`.
3. Проверьте:

```bash
cd /home/ilya/nixos-config
git diff
journalctl --user -b | rg -i "hypr|error|wayland"
systemctl status display-manager
```

4. Откатитесь через boot menu или исправьте `home/ilya/hypr/hyprland.nix`.

## Waybar не стартует

```bash
waybar
journalctl --user -b | rg -i waybar
bat home/ilya/waybar/waybar.nix
```

## Portals/screen sharing

В `modules/nixos/desktop.nix` включены:

```nix
xdg-desktop-portal-hyprland
xdg-desktop-portal-gtk
```

Проверка:

```bash
systemctl --user status xdg-desktop-portal
systemctl --user status xdg-desktop-portal-hyprland
journalctl --user -b | rg -i "portal|pipewire"
```

## Нет clipboard

```bash
pgrep -a wl-paste
wl-copy <<< test
wl-paste
cliphist list
```

## Не работают скриншоты

```bash
command -v grim slurp swappy
grim -g "$(slurp)" - | swappy -f -
```

## Не работает volume/brightness

```bash
command -v pamixer brightnessctl swayosd-client playerctl
pamixer --get-volume
brightnessctl
playerctl status
```

Проверьте права на brightness device, PipeWire/PulseAudio и наличие `swayosd-server`.

## Fonts/icons

```bash
fc-match "JetBrainsMono Nerd Font"
fc-match "Inter"
fc-match "Papirus-Dark"
```

## Читать логи

```bash
journalctl --user -b
journalctl --user -b -p warning
journalctl -b -p err
```

## Cheatsheet

```bash
hyprctl reload
hyprctl monitors
hyprctl clients
journalctl --user -b | rg -i hypr
systemctl --user status xdg-desktop-portal-hyprland
```
