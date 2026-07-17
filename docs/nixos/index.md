# NixOS: как думать о системе

## Назначение

NixOS - декларативный Linux-дистрибутив: состояние системы описывается в `.nix`-файлах, а не собирается вручную из разрозненных команд. Для этой машины главный вход - `/home/ilya/nixos-config/flake.nix`.

## Когда пользоваться этим разделом

Читайте его перед изменением системных пакетов, сервисов, Hyprland/KDE, boot loader, сети, шрифтов, shell, Home Manager или при ошибках rebuild.

## Отличие от Arch

В Arch типичный подход: поставить пакет через pacman, поправить файлы в `/etc`, помнить историю действий. В NixOS подход другой: изменить репозиторий, собрать generation, применить. Если изменение плохое, откатиться на старую generation.

## Декларативная конфигурация

Файлы этой системы:

```bash
flake.nix
hosts/nixos/configuration.nix
modules/nixos/*.nix
home/ilya/home.nix
home/ilya/*/*.nix
```

Система не должна зависеть от случайных ручных установок. Если программа нужна постоянно, добавьте ее в `environment.systemPackages` или `home.packages`, но только после проверки.

## Generations

Каждый успешный `switch` создает поколение. Boot menu позволяет выбрать старое поколение. Home Manager тоже имеет свои generations.

```bash
nh os info
home-manager generations
```

## Nix store

`/nix/store` хранит immutable сборки пакетов и конфигураций. Он растет, потому что старые поколения ссылаются на старые версии пакетов. Чистка описана в [garbage-collection.md](garbage-collection.md).

## Rebuild

Базовый workflow:

```bash
cd /home/ilya/nixos-config
git diff
nh os test /home/ilya/nixos-config
git add -A
git commit -m "Describe the configuration change"
nh os switch /home/ilya/nixos-config
```

## Частые ошибки

- Ожидать, что правка в `/etc` переживет rebuild.
- Ставить программы глобально обходными способами.
- Удалять старые generations до проверки нового состояния.
- Путать system packages и home packages.

## Troubleshooting

Начинайте с:

```bash
git diff
nix flake check /home/ilya/nixos-config
nh os test /home/ilya/nixos-config
journalctl -b -p err
```

## Cheatsheet

```bash
nh os test /home/ilya/nixos-config
nh os switch /home/ilya/nixos-config
nh os info
sudo nixos-rebuild switch --rollback
home-manager generations
```
