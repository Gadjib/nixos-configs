# NixOS troubleshooting

## Ошибка сборки

```bash
cd /home/ilya/nixos-config
git diff
nh os test /home/ilya/nixos-config
sudo nixos-rebuild test --flake .#thinkpad-nix --show-trace
```

Читайте первое содержательное `error:` и ближайший путь `*.nix:line:column`.

## Пакет не найден

```bash
nix search nixpkgs name
rg "name" home modules
```

Возможные причины: неправильное имя атрибута, пакет не в `nixos-26.05`, нужен namespace (`kdePackages.*`, `python3Packages.*`).

## Конфликт options

Ищите option:

```bash
rg "option.name|programs.hyprland|services.xserver" .
```

Конфликт часто означает, что одну и ту же вещь включили в системном модуле и Home Manager несовместимым способом.

## Flake не видит hostname

В этом repo output называется `nixosConfigurations.thinkpad-nix`. Команда:

```bash
sudo nixos-rebuild test --flake /home/ilya/nixos-config#thinkpad-nix
```

Если переименовали output, обновите команды и docs.

## Home Manager не применился

Проверьте, что rebuild прошел через flake:

```bash
home-manager generations
ls -la ~/.config/hypr ~/.config/waybar ~/.config/fish
```

Home Manager подключен в `flake.nix`, поэтому отдельный `home-manager switch` обычно не нужен.

## Не хватает места в /boot

```bash
df -h /boot
bootctl list
nh os info
```

Проверьте `configurationLimit = 10`. После стабильной работы можно чистить старые поколения.

## Не стартует display manager

```bash
systemctl status display-manager
journalctl -b -u display-manager
journalctl -b -p err
```

Зайдите в TTY, выберите старую generation или KDE fallback.

## Нет сети

```bash
systemctl status NetworkManager
nmcli device status
ip addr
ip route
dig example.com
```

## Fish сломан

```bash
bash
fish --no-config
fish -n ~/.config/fish/config.fish
bat home/ilya/fish/fish.nix
```

## Hyprland не появляется в SDDM

Проверьте:

```bash
rg "programs.hyprland|displayManager|plasma6" modules hosts
ls /run/current-system/sw/share/wayland-sessions
systemctl restart display-manager
```

В `modules/nixos/desktop.nix` включены SDDM, Plasma 6 и Hyprland.

## Cheatsheet

```bash
git diff
nh os test /home/ilya/nixos-config
sudo nixos-rebuild test --flake .#thinkpad-nix --show-trace
systemctl --failed
journalctl -b -p err
df -h /boot
```
