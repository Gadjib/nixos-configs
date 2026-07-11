# Пакеты в NixOS

## Назначение

Пакеты можно ставить системно, пользовательски или запускать временно. В NixOS лучше фиксировать постоянные зависимости декларативно.

## System packages

Файл: `modules/nixos/packages.nix`.

Там находятся базовые системные инструменты: `vim`, `curl`, `wget`, `git`, `kitty`, `dolphin`, `kate`, hardware/network/dev tools (`lshw`, `smartmontools`, `dnsutils`, `tcpdump`, `gcc`, `go`, `rustup`, `uv`).

Используйте system package, если программа нужна всем пользователям, system services или emergency/TTY.

## Home packages

Файл: `home/ilya/home.nix`.

Там находятся пользовательские программы: Hyprland-окружение, `starship`, `zoxide`, `fzf`, `bat`, `eza`, `fd`, `ripgrep`, `btop`, `dust`, `duf`, `procs`, `yazi`, `trash-cli`, `jq`, `yq`, `httpie`, `lazygit`, `delta`, `gh`, `direnv`.

Дополнительно `home/ilya/home.nix` импортирует `home/ilya/packages/manual.nix`. Этот файл предназначен для пакетов, добавленных интерактивным helper `install`; сейчас там есть:

```nix
bitwarden-cli
discord
fastfetch
ffmpeg
glow
vlc
vscode
```

В fish настроена функция:

```fish
install <pkgname>
```

Она не ставит пакет imperatively. Она проверяет пакет в текущем flake, добавляет имя в `home/ilya/packages/manual.nix`, делает dry-run build и запускает `nh os switch /home/ilya/nixos-config`. Если вызвать `install` с option-like аргументами, функция передает выполнение обычному coreutils `install`.

Используйте helper осознанно: он меняет Nix-файл и применяет систему. Перед этим полезно выполнить:

```bash
cd /home/ilya/nixos-config
git status
```

## Временно попробовать пакет

```bash
nix shell nixpkgs#package
nix run nixpkgs#package
```

Примеры:

```bash
nix shell nixpkgs#glow
glow docs
nix run nixpkgs#hello
```

## Поиск пакета

Если доступен индекс:

```bash
nix search nixpkgs glow
nix search nixpkgs markdown
```

Offline поиск может быть ограничен тем, что уже есть в flake/nixpkgs input.

## Удаление пакета

Удаляйте декларативно: уберите пакет из `environment.systemPackages` или `home.packages`, затем:

```bash
nh os test /home/ilya/nixos-config
nh os switch /home/ilya/nixos-config
```

После проверки можно чистить store.

## Почему не npm -g/curl | sh

Глобальные установки обходят NixOS-модель, сложнее откатываются, могут конфликтовать с system libraries и теряются в документации. Для проектов лучше `devShell`, `direnv`, `uv`, `cargo`, `go`, `npm` локально в проекте.

## Troubleshooting

```bash
command -v package
nix shell nixpkgs#package
home-manager packages | rg package
rg "package" home modules
```

## Cheatsheet

```bash
nix shell nixpkgs#pkg
nix run nixpkgs#pkg
nix search nixpkgs pkg
install pkg
nvim home/ilya/home.nix
nvim home/ilya/packages/manual.nix
nvim modules/nixos/packages.nix
nh os test /home/ilya/nixos-config
```
