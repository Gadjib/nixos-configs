# Обзор системы

## Назначение

Это карта твоей NixOS-системы: какие части управляются NixOS, какие Home Manager, где Hyprland, зачем KDE fallback и как не сломать рабочее окружение.

## Архитектура

Репозиторий: `/home/ilya/nixos-config`.

Flake `flake.nix` использует:

- `nixpkgs.url = github:NixOS/nixpkgs/nixos-26.05`;
- `home-manager.url = github:nix-community/home-manager/release-26.05`;
- `nixosConfigurations.thinkpad-nix` для хоста `thinkpad-nix`;
- встроенный Home Manager module для пользователя `ilya`.

Хостовая конфигурация: `hosts/nixos/configuration.nix`. Она подключает hardware config и модули из `modules/nixos/`.

## NixOS

NixOS управляет системой декларативно: boot loader, kernel, system services, users, desktop manager, пакеты, шрифты, NetworkManager. В этой системе:

- GRUB включен в UEFI mode;
- `boot.loader.grub.useOSProber = true`, чтобы GRUB искал Windows Boot Manager
  на соседних разделах dual boot;
- `configurationLimit = 10`, то есть boot menu хранит ограничение поколений;
- kernel - `linuxPackages_latest`;
- hostname - `thinkpad-nix`;
- timezone - `Europe/Moscow`;
- NetworkManager включен;
- KDE Plasma 6 включен как fallback;
- SDDM включен как display manager;
- Hyprland включен как Wayland compositor;
- PipeWire, Bluetooth, power-profiles-daemon и upower включены.
- `/swapfile` управляется NixOS декларативно и имеет размер 16 GiB;
  systemd initrd использует UEFI `HibernateLocation` для динамического resume
  из swapfile без статического offset.
- Suspend использует ACPI S3 (`deep`); крышка и пункт Wlogout запускают
  suspend-then-hibernate с переходом в hibernate через 2 часа. Idle в
  Hyprland по-прежнему управляет только lock/DPMS, без автоматического suspend.

## KDE fallback

KDE Plasma 6 установлена и включена. Если Hyprland сломался, на экране SDDM можно выбрать Plasma session и войти в графическую среду. Это важная страховка: не удаляйте KDE fallback без отдельной причины.

## Hyprland

Hyprland - основная сессия. Системно он включен в `modules/nixos/desktop.nix`, а пользовательская настройка лежит в `home/ilya/hypr/hyprland.nix` через Home Manager.

Компоненты Hyprland-окружения:

- `waybar` - верхняя панель;
- `rofi` - launcher, run menu, window menu;
- `mako` - уведомления;
- `awww-daemon` - wallpaper daemon из пакета `awww`;
- `hyprlock` - lock screen;
- `hypridle` - idle/lock/DPMS;
- `wlogout` - logout/power menu;
- `grim`, `slurp`, `swappy` - screenshots;
- `wl-clipboard`, `cliphist` - clipboard и history;
- `swayosd` - OSD для громкости/яркости;
- `nm-applet` - NetworkManager tray;
- `blueman-applet` - Bluetooth tray.

## Home Manager

Home Manager управляет пользовательским окружением:

- `home.packages` содержит CLI и Hyprland tools;
- `home/ilya/appearance.nix` является единым источником масштаба, курсора,
  иконок, шрифтов и имен GTK/Qt/KDE themes;
- `home/ilya/packages/manual.nix` содержит актуальный список пакетов, добавленных helper-ом `nix-install`;
- `programs.fish` включает Fish, Oh My Fish с Agnoster, zoxide, direnv, fzf и
  алиасы; Starship остается установленным, но не интегрируется в Fish;
- `programs.kitty`, `programs.rofi`, `services.mako`, `programs.waybar`;
- `wayland.windowManager.hyprland`;
- `xdg.configFile` для Qt/KDE/Hyprland config files.
- `hyprland-mimeapps.list` задает Hyprland default applications: images -> Gwenview,
  video/audio -> VLC, PDFs/docs -> Okular, archives -> Ark,
  directories -> Dolphin, text -> Kate, code/config -> VSCode, web -> Firefox.
  Эти associations теперь записываются в desktop-specific
  `hyprland-mimeapps.list`; Plasma не наследует их.
- KDE/Qt theme support includes `~/.config/kdeglobals`,
  `~/.local/share/color-schemes/CatppuccinMacchiatoBlue.colors`, qt5ct/qt6ct
  configs, Kvantum Catppuccin Macchiato Blue for Qt widgets/toolbars, and
  explicit GTK4 Catppuccin css/assets links.
- Home Manager синхронизирует курсор из `appearance.nix` с Hyprcursor,
  XCursor/Xresources, GTK, dconf и compatibility links. Wayland-приложения
  используют scale `1.25`, а `xwayland.force_zero_scaling` оставляет X11
  приложения и игры в масштабе `1` с физическим разрешением `1920x1200`.
- Bundled Qt GUI Happ запускается через Wayland QPA с fallback на `xcb`, чтобы
  touchpad scrolling в Hyprland не проходил через XWayland wheel emulation.

## Независимость Hyprland и Plasma

Оба окружения работают под пользователем `ilya`, поэтому данные Steam,
Telegram, браузеров и других обычных приложений остаются общими. Изолирован
только слой desktop environment.

`home/ilya/desktop-session-isolation.nix` временно устанавливает текущие
Catppuccin GTK/KDE/dconf settings при старте `hyprland-session.target` и
возвращает собственные writable settings Plasma при выходе. Hyprland-specific
environment variables также задаются только из Hyprland config.

Переключением управляет `home/ilya/desktop-session-profile.sh`. Перед
изменением активных файлов он сохраняет полный снимок Plasma; восстановление
копирует файлы из снимка, поэтому его можно повторить после прерывания.
Завершённые снимки остаются в
`~/.local/state/nixos-desktop-isolation/backups/completed.*/snapshot`.
Старый формат состояния сохраняется отдельно перед миграцией. Автоматической
очистки этих резервных копий нет.

При самом первом входе настройки Plasma сбрасываются к штатным, но сначала
полностью сохраняются в `~/.local/state/nixos-desktop-isolation/initial-reset-v2`.
Маркер `plasma-reset-v1` предотвращает повторный сброс; на уже настроенной машине
он сохраняется. Последующие изменения из Plasma System Settings сохраняются.
Одновременные сессии Plasma и Hyprland под одним пользователем не поддерживаются.
Перед откатом на поколение со старым скриптом нужно нормально выйти из Hyprland,
чтобы новый скрипт успел восстановить настройки Plasma.

`nm-applet`, `blueman-applet` и `udiskie` запускаются исключительно с
`hyprland-session.target`. Plasma использует свои NetworkManager, BlueDevil и
device-notifier applets, поэтому duplicate tray icons и конкурирующее
автомонтирование исключены.

## CLI stack

Повседневные замены:

| Старое | Новое |
|---|---|
| `ls` | `eza` |
| `cat` | `bat` |
| `find` | `fd` |
| `grep` | `rg` |
| `cd` | `zoxide` (`z`, `zi`) |
| `top` | `btop` |
| `du` | `dust` |
| `df` | `duf` |
| `ps` | `procs` |
| file manager | `yazi` |
| git UI | `lazygit` |
| API | `http`, `curl`, `jq`, `yq` |

## Что управляется вручную

Yazi-конфиг в репозитории не найден, `~/.config/yazi` отсутствует. Значит Yazi сейчас, вероятно, работает на дефолтах. Если добавите `~/.config/yazi/*.toml`, лучше перенести это в Home Manager через `xdg.configFile`.

Fish-функция `nix-install` в `home/ilya/fish/fish.nix` вызывает
`/home/ilya/.local/bin/nix-install-package`. Helper работает только на чистом
Git worktree, добавляет пакеты в `home/ilya/packages/manual.nix`, проверяет
dry-run, коммитит изменение и лишь затем делает switch. Обычная coreutils-команда
`install` не переопределяется.

Некоторые программы могут хранить runtime state в `~/.local/share`, `~/.cache`, `~/.config`. Не все такие файлы должны попадать в Nix.

## Как не сломать систему

- Перед изменениями: `git status && git diff`.
- Менять сначала маленькими шагами.
- Для NixOS сначала `nh os test /home/ilya/nixos-config`, затем commit проверенного состояния и только потом `nh os switch /home/ilya/nixos-config`.
- Не удалять boot generations, пока новая система не проверена.
- Не делать агрессивный garbage collection сразу после крупного изменения.
- Не ставить системные программы через `curl | sh`, если они могут быть в Nix.

## Troubleshooting

```bash
systemctl status display-manager
journalctl -b -p warning
home-manager generations
nh os info
hyprctl monitors
```

## Cheatsheet

```bash
cd /home/ilya/nixos-config
bat flake.nix
bat hosts/nixos/configuration.nix
bat home/ilya/home.nix
bat home/ilya/hypr/hyprland.nix
nh os test /home/ilya/nixos-config
git add -A
git commit -m "Describe the configuration change"
nh os switch /home/ilya/nixos-config
```
