# Home Manager

## Назначение

Home Manager декларативно управляет пользовательским окружением: shell, терминал, Hyprland config, панель, launcher, уведомления, user packages, XDG config files.

## Где он подключен

В `flake.nix` используется `home-manager.nixosModules.home-manager`, а пользователь `ilya` импортируется из `home/ilya/home.nix`. Поэтому обычный `nh os switch /home/ilya/nixos-config` применяет и системную, и пользовательскую часть.

## Что держать в Home Manager

- CLI-программы для пользователя: `bat`, `eza`, `fd`, `ripgrep`, `yazi`, `lazygit`.
- Ручной список пользовательских пакетов в `home/ilya/packages/manual.nix`: сейчас `bitwarden-cli`, `discord`, `fastfetch`, `ffmpeg`, `glow`, `vlc`, `vscode`.
- Настройки fish, kitty, rofi, mako, waybar.
- Hyprland keybindings и user-level autostart.
- Темы пользователя, XDG-файлы, dotfiles.

## Что не держать в Home Manager

- Boot loader, kernel, users, NetworkManager, PipeWire, SDDM, KDE.
- System services, которые должны жить до пользовательского логина.
- Драйверы, hardware support, system fonts как базу системы.

## Важные options

```nix
home.packages = with pkgs; [ yazi ripgrep bat ];
programs.fish.enable = true;
programs.kitty.enable = true;
wayland.windowManager.hyprland.enable = true;
xdg.configFile."path".text = "...";
```

В твоей системе есть:

- `programs.fish` с starship, zoxide, direnv, fzf;
- fish function `install`, которая вызывает `/home/ilya/.local/bin/nix-install-package` для добавления пакетов в `home/ilya/packages/manual.nix`;
- `programs.delta` и git integration;
- `programs.direnv.nix-direnv`;
- `xdg.configFile` для qt5ct/qt6ct/kdeglobals и hyprlock/hypridle.
- `xdg.mimeApps` для default applications. Если файл из Yazi открывается не той
  программой, сначала смотреть `home/ilya/home.nix`, а не править
  `~/.config/mimeapps.list` вручную.

## Команды

Обычно:

```bash
nh os test /home/ilya/nixos-config
nh os switch /home/ilya/nixos-config
```

Отдельные Home Manager команды:

```bash
home-manager generations
home-manager switch --rollback
home-manager packages
home-manager option programs.fish.enable
```

## Типичные ошибки

- Конфликт существующего файла в `~/.config`; в flake задан `backupFileExtension = "hm-backup"`.
- Пакет добавлен в system packages, хотя нужен только пользователю.
- Ручная правка generated `~/.config/hypr/hyprland.conf`, которая исчезнет после rebuild.

## Troubleshooting

```bash
home-manager generations
home-manager packages
ls -la ~/.config/hypr ~/.config/waybar ~/.config/fish
git diff home/ilya
nh os test /home/ilya/nixos-config
```

## Cheatsheet

```bash
nvim home/ilya/home.nix
nvim home/ilya/fish/fish.nix
home-manager generations
home-manager switch --rollback
nh os test /home/ilya/nixos-config
```
