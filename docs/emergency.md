# Emergency guide

## Назначение

Offline-инструкция для случаев, когда графика, Hyprland, сеть, shell или rebuild сломались. Держите этот файл доступным через `less docs/emergency.md`.

## Если Hyprland не стартует

1. На SDDM выберите сессию KDE Plasma вместо Hyprland.
2. Если SDDM не дает войти, откройте TTY: `Ctrl+Alt+F2` или `Ctrl+Alt+F3`.
3. Войдите под пользователем `ilya`.
4. Перейдите в конфиг:

```bash
cd /home/ilya/nixos-config
git status
git diff
```

5. Проверьте логи:

```bash
systemctl status display-manager
journalctl -b -u display-manager
journalctl -b -p err
```

## Откат через boot menu

При включении выберите предыдущую NixOS generation в GRUB. Это самый надежный rollback, если новая generation не грузится или не дает войти.

После входа:

```bash
cd /home/ilya/nixos-config
git status
git diff
```

Исправьте конфиг или верните проблемное изменение.

## Rollback из рабочей системы

```bash
sudo nixos-rebuild switch --rollback
nh os rollback
home-manager switch --rollback
```

Если flake-команда нужна вручную:

```bash
sudo nixos-rebuild switch --flake /home/ilya/nixos-config#nixos
```

## Проверить место на диске

```bash
df -h
duf
sudo du -h -d 1 /nix 2>/dev/null
dust /nix/store
df -h /boot
```

Если `/boot` переполнен, см. [nixos/garbage-collection.md](nixos/garbage-collection.md). В конфиге стоит `boot.loader.grub.configurationLimit = 10`.

Осторожная чистка:

```bash
sudo nix-collect-garbage --delete-older-than 14d
```

Агрессивная:

```bash
sudo nix-collect-garbage -d
```

## Fish shell сломан

Запустить bash временно:

```bash
bash
/run/current-system/sw/bin/bash
```

Проверить fish config:

```bash
fish --no-config
fish -n /home/ilya/.config/fish/config.fish
bat /home/ilya/nixos-config/home/ilya/fish/fish.nix
```

Если проблема в Home Manager, исправьте `home/ilya/fish/fish.nix` и выполните rebuild/test.

## Проверить сеть

```bash
ip addr
ip route
nmcli device status
nmcli connection show
ping -c 3 1.1.1.1
dig nixos.org
```

Поднять NetworkManager:

```bash
sudo systemctl status NetworkManager
sudo systemctl restart NetworkManager
nmcli radio wifi on
nmcli device wifi list
nmcli device wifi connect SSID --ask
```

Если IP есть, но DNS не работает, проверяйте `resolvectl status` и `dig @1.1.1.1 example.com`.

## Перезапустить display manager

Это выбросит из графической сессии:

```bash
sudo systemctl restart display-manager
```

Лучше сначала сохранить работу. Для логов:

```bash
journalctl -b -u display-manager
```

## Вернуться в KDE fallback

На экране SDDM выберите Plasma. KDE включена в `modules/nixos/desktop.nix` через `services.desktopManager.plasma6.enable = true`.

## Типичные команды диагностики

```bash
systemctl --failed
systemctl status display-manager
systemctl status NetworkManager
journalctl -b -p warning
journalctl -b -p err
nh os info
home-manager generations
hyprctl monitors
```

## Частые ошибки

- Удалили старые generations до проверки новой системы.
- Чистите `/nix/store` агрессивно, когда нужен rollback.
- Правите generated файлы в `~/.config`, забывая, что они управляются Home Manager.
- Перезапускаете display-manager из живой сессии без сохранения работы.

## Cheatsheet

```bash
Ctrl+Alt+F2
cd /home/ilya/nixos-config
git diff
systemctl status display-manager
journalctl -b -p err
df -h /boot
sudo nixos-rebuild switch --rollback
sudo systemctl restart NetworkManager
bash
```
