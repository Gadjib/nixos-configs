# NixOS + Hyprland Setup Notes

Этот файл - карта текущего состояния `/home/ilya/nixos-config` для будущих
агентов и для ручного обслуживания. Его задача: дать новому агенту с пустым
контекстом достаточно точное понимание системы, чтобы он мог продолжать работу
как продолжение предыдущей сессии, а не начинать аудит с нуля.

## Обязательное Правило

После каждого содержательного изменения конфигурации нужно обновлять этот файл.

Обновлять нужно не как changelog в конец файла, а по месту: если поменялся
Waybar, правится раздел Waybar; если добавлен скрипт, правится раздел про
скрипты; если изменился workflow, правится раздел workflow. Текст должен
оставаться описанием актуального состояния системы, а не историей всех правок.

С пользователем нужно общаться на русском. Команды, пути, имена опций, имена
пакетов и идентификаторы оставлять в оригинальном написании.

Перед тем как предлагать пользователю выполнить `rebuild-switch` или
эквивалентный `nh os switch /home/ilya/nixos-config`, нужно сначала закоммитить
актуальное состояние репозитория. Идея: любой switch должен иметь понятную
точку отката в Git. Исключение допустимо только если пользователь явно просит не
коммитить или если commit технически невозможен; в таком случае нужно сказать об
этом прямо до команды switch.

Push в remote не делать после каждого commit. Нормальный режим: пушить пачкой
примерно каждые 5 локальных commit или если с предыдущего push прошло больше
суток. Если пользователь явно просит push, push делать сразу.

## Машина

- Hostname: `nixos`
- User: `ilya`
- Архитектура: `x86_64-linux`
- Time zone: `Europe/Moscow`
- NixOS state version: `26.05`
- Home Manager state version: `26.05`
- Flake input Nixpkgs: `github:NixOS/nixpkgs/nixos-26.05`
- Flake input Home Manager: `github:nix-community/home-manager/release-26.05`
- Основной рабочий desktop: Hyprland
- Fallback desktop: KDE Plasma через SDDM

## Инварианты

`hardware-configuration.nix` не трогать без крайней необходимости. Если кажется,
что его нужно менять, сначала объяснить пользователю причину.

KDE Plasma, SDDM и возможность зайти в KDE должны оставаться. Hyprland - основная
сессия, KDE - аварийный fallback.

Не добавлять AGS, Eww, Quickshell, Hyprland plugins, custom kernel,
impermanence, Stylix или чужие dotfiles без отдельного явного решения.

Предпочитать декларативный NixOS/Home Manager подход. Ручные runtime-изменения
допустимы для проверки, но финальное состояние должно быть отражено в конфиге.

## Структура Репозитория

Репозиторий flake-based. Главная система называется:

```text
nixosConfigurations.nixos
```

Актуальная структура важных файлов:

```text
/home/ilya/nixos-config
├── flake.nix
├── flake.lock
├── configuration.nix
├── hardware-configuration.nix
├── NOTES.md
├── docs/
├── hosts/nixos/configuration.nix
├── modules/nixos/
│   ├── desktop.nix
│   ├── happ.nix
│   ├── incy.nix
│   ├── nix.nix
│   ├── packages.nix
│   ├── compat.nix
│   ├── smb.nix
│   └── users.nix
└── home/ilya/
    ├── home.nix
    ├── firefox/firefox.nix
    ├── fish/fish.nix
    ├── hypr/hyprland.nix
    ├── kitty/kitty.nix
    ├── mako/mako.nix
    ├── nvim/nvim.nix
    ├── packages/manual.nix
    ├── rofi/rofi.nix
    ├── rofi/theme.rasi
    ├── scripts/network-menus.nix
    ├── scripts/package-installer.nix
    ├── starship/starship.nix
    ├── telegram/telegram.nix
    ├── waybar/waybar.nix
    └── wlogout/wlogout.nix
```

`docs/` содержит справочные заметки и cheatsheets. Они полезны пользователю, но
`NOTES.md` остается главным файлом для агентского контекста.

`home/ilya/packages/manual.nix.backup.*` - backup-файлы, созданные helper-ом
`install`. Они не являются активным конфигом.

## Entrypoints

`flake.nix` подключает:

- `./hosts/nixos/configuration.nix`
- `home-manager.nixosModules.home-manager`
- `home-manager.users.ilya = import ./home/ilya/home.nix`

Home Manager встроен как NixOS module. Основной workflow - `nh os switch`, а не
отдельный `home-manager switch`.

`home-manager.backupCommand` задан в `flake.nix` через
`pkgs.writeShellScript "home-manager-timestamped-backup"`. При конфликте
управляемого Home Manager файла с уже существующим обычным файлом скрипт
переносит существующий файл в уникальное имя рядом:
`<file>.hm-backup.<UTC timestamp>`. Это заменяет старый фиксированный
`backupFileExtension = "hm-backup-v2"`, который периодически ломал activation:
Home Manager пытался создать один и тот же backup-файл повторно и падал с
ошибкой вида `Existing file ... would be clobbered`.

Корневой `configuration.nix` - thin wrapper для совместимости:

```nix
{
  imports = [
    ./hosts/nixos/configuration.nix
  ];
}
```

Основной host config: `hosts/nixos/configuration.nix`. Он импортирует hardware
config и системные модули.

## Системный Слой NixOS

### `modules/nixos/nix.nix`

Включает:

- `nix-command`
- `flakes`
- `auto-optimise-store`
- weekly GC старше 14 дней
- `programs.nh.enable = true`

Системные Nix tools:

- `home-manager`
- `nh`
- `nix-output-monitor`
- `nix-tree`
- `nix-diff`
- `nvd`

`programs.nh.clean` не включен, чтобы не конфликтовать с `nix.gc.automatic`.

### `modules/nixos/desktop.nix`

Оставляет fallback-графику:

- `services.displayManager.sddm.enable = true`
- `services.displayManager.sddm.wayland.enable = true`
- `services.desktopManager.plasma6.enable = true`

Включает Hyprland системно:

- `programs.hyprland.enable = true`
- `programs.hyprland.xwayland.enable = true`

Порталы:

- `xdg-desktop-portal-hyprland`
- `xdg-desktop-portal-gtk`

Audio:

- PipeWire
- ALSA
- ALSA 32-bit
- PulseAudio compatibility
- RTKit

Сервисы:

- Bluetooth
- Blueman
- `power-profiles-daemon`
- UPower
- Polkit
- dconf

SMB mount:

- `modules/nixos/smb.nix` mounts `//192.168.0.10/home` at `/mnt/home` using
  the standard SMB port.
- It uses `x-systemd.automount`, `noauto`, `_netdev`, `nofail`, so boot should
  not block if the NAS is offline.
- Auth uses `/etc/samba/vault.credentials`, which must stay outside git.
  It should contain `username=...`, `password=...`, and optionally
  `domain=WORKGROUP`.
- `cifs-utils` is installed system-wide for `mount.cifs` diagnostics.

Закрытие крышки явно отправляет ноут в сон:

```nix
services.logind.settings.Login = {
  HandleLidSwitch = "suspend";
  HandleLidSwitchExternalPower = "suspend";
  HandleLidSwitchDocked = "suspend";
};
```

Шрифты:

- Inter
- Font Awesome
- JetBrainsMono Nerd Font
- FiraCode Nerd Font
- Noto fonts
- Noto CJK
- Noto Color Emoji

Default fontconfig:

- monospace: `JetBrainsMono Nerd Font`
- sans: `Inter`, `Noto Sans`
- serif: `Noto Serif`
- emoji: `Noto Color Emoji`

Bootloader:

- GRUB is enabled in UEFI mode in `hosts/nixos/configuration.nix`.
- `boot.loader.grub.device = "nodev"` because this is an EFI install.
- `boot.loader.grub.useOSProber = true` is intentional: Windows is installed
  as a dual-boot system on the same NVMe disk but appears to use a different
  EFI partition from NixOS, so `systemd-boot` did not show it reliably.
- `boot.loader.grub.configurationLimit = 10` keeps the number of NixOS boot
  entries bounded.
- Do not modify disk partitions for this. The intended fix is only bootloader
  config plus a rebuild/switch.

### `modules/nixos/packages.nix`

Системные пакеты: Firefox, Kitty, Dolphin, Kate, Thunar, `nwg-look`, `qt5ct`,
`qt6ct`, Papirus, Bibata, pavucontrol, blueman, brightness/audio helpers,
hardware/network diagnostics including `efibootmgr` and `os-prober`,
compiler/dev tools, `codex`.

Версионно важные имена:

- Dolphin: `kdePackages.dolphin`
- Kate: `kdePackages.kate`
- Qt 5 config tool: `libsForQt5.qt5ct`
- Qt 6 config tool: `qt6Packages.qt6ct`

### `modules/nixos/users.nix`

Пользователь:

```nix
users.users.ilya = {
  isNormalUser = true;
  description = "ilya";
  extraGroups = [ "networkmanager" "wheel" ];
  shell = pkgs.fish;
};
```

Fish включен системно через `programs.fish.enable = true`.

## Home Manager

Главный пользовательский файл: `home/ilya/home.nix`.

Он импортирует модули для:

- Firefox Hyprland wrapper
- Fish
- Hyprland
- Kitty
- Mako
- Neovim
- ручных пакетов `manual.nix`
- Rofi
- network menus
- package installer
- Starship
- Telegram Hyprland wrapper
- Waybar
- Wlogout

Home Manager также задает session variables:

- `EDITOR = "nvim"`
- `TERMINAL = "kitty"`
- `BROWSER = "firefox"`
- cursor theme/size
- GTK dark preference
- Qt platform theme `kde`
- Qt Quick Controls style `org.kde.desktop`
- `XDG_CURRENT_DESKTOP = "Hyprland"`
- `XDG_SESSION_DESKTOP = "Hyprland"`

Cursor size is `30`, matching the enlarged Hyprland scale.

Глобальная тема задана без Stylix и без тяжелого theming framework.
Базовая палитра: Catppuccin Macchiato Blue. Это нежно-темно-синяя схема:
темная база `#24273a`, основной текст `#cad3f5`, синий акцент `#8aadf4`,
фиолетовый вторичный акцент `#c6a0f6`.

- GTK: `catppuccin-macchiato-blue-standard`, пакет `catppuccin-gtk`
  с `variant = "macchiato"`, `accents = [ "blue" ]`, `size = "standard"`.
- dconf: `org/gnome/desktop/interface color-scheme = prefer-dark` и тот же
  GTK theme name.
- Qt/KDE apps in Hyprland use `QT_QPA_PLATFORMTHEME=kde` and
  `QT_QUICK_CONTROLS_STYLE=org.kde.desktop`. This is intentional: KDE/Kirigami
  apps such as Plasma System Monitor need KDE platform integration to consume
  `kdeglobals` and the dark Catppuccin palette reliably. Earlier global
  `QT_QPA_PLATFORMTHEME=qt6ct` plus `QT_STYLE_OVERRIDE=kvantum` made some
  KDE/QtQuick surfaces fall back to light colors.
- `kdePackages.plasma-integration` and `kdePackages.qqc2-desktop-style` are
  installed explicitly for KDE apps launched outside Plasma.
- Generated `qt5ct.conf` / `qt6ct.conf` still exist and use `style=kvantum`
  with local `catppuccin-macchiato.conf` color schemes, but they are no longer
  the global platform theme for the Hyprland session.
- Kvantum is installed for both Qt 5 and Qt 6 via `libsForQt5.qtstyleplugin-kvantum`
  and `kdePackages.qtstyleplugin-kvantum`. The active Kvantum theme is
  `catppuccin-macchiato-blue` from `catppuccin-kvantum`.
- KDE globals: `ColorScheme=CatppuccinMacchiatoBlue`, Papirus-Dark icons.
  Пакет `catppuccin-kde` добавлен с `flavour = [ "macchiato" ]` и
  `accents = [ "blue" ]`, чтобы схема была доступна в Plasma settings.
- KDE color scheme is also explicitly exposed through Home Manager at
  `~/.local/share/color-schemes/CatppuccinMacchiatoBlue.colors`; this matters
  for KDE apps such as Gwenview launched from Hyprland.
- `~/.config/kdeglobals` embeds the full Catppuccin `[Colors:*]` sections, not
  only `ColorScheme=CatppuccinMacchiatoBlue`. KDE apps outside Plasma do not
  reliably expand the scheme name by themselves.
- GTK4 theme files are explicitly linked from Catppuccin into
  `~/.config/gtk-4.0/gtk.css`, `gtk-dark.css`, and `assets`.
- Kitty, Rofi, Mako, Waybar, Wlogout, Starship, Hyprland borders and
  Hyprlock use the same Macchiato palette directly in their own modules.

XDG default applications are managed declaratively in `home/ilya/home.nix` via
`xdg.mimeApps`. This is intentional because runtime `~/.config/mimeapps.list`
previously made images open in Firefox from Yazi.

Current default app policy:

- web links and HTML: `firefox.desktop`.
- Telegram links: `org.telegram.desktop.desktop`.
- images: `org.kde.gwenview.desktop`.
- video/audio: `vlc.desktop`.
- PDFs and document-like files: Okular desktop entries.
- archives: `org.kde.ark.desktop`.
- directories: `org.kde.dolphin.desktop`.
- plain text: `org.kde.kate.desktop`.
- code/config formats: `code.desktop`.

`firefox-hyprland.desktop` intentionally does not advertise image MIME types.
It exists for Hyprland browser keybindings/window buttons, not as a general
image viewer.

## Пользовательские Пакеты

Базовые Home Manager пакеты лежат в `home/ilya/home.nix`.

Туда входят Hyprland stack, CLI tools, Bitwarden Desktop, Telegram,
`networkmanagerapplet`, Catppuccin GTK/KDE themes, `direnv`, `nix-direnv`,
`lazygit`, `delta`, `gh` и прочее.

Ручные пакеты, добавленные командой `install`, лежат отдельно:

```text
home/ilya/packages/manual.nix
```

Текущий список: `bitwarden-cli`, `discord`, `fastfetch`, `ffmpeg`, `glow`,
`vlc`, `vscode`, `stress-ng`, `texliveFull`, `prismlauncher`, `tlauncher`,
`incy`, `qbittorrent`, `zip`, `spotify`.

`spotify` в этом списке - не прямой `pkgs.spotify`, а локальный wrapper
`home/ilya/packages/spotify.nix`. Он оставляет upstream пакет из nixpkgs, но
подменяет `bin/spotify` и desktop entry так, чтобы Spotify запускался с
`NIXOS_OZONE_WL=1`, `--ozone-platform=wayland` и
`--force-device-scale-factor=1.10`. Это нужно под текущий Hyprland scale `1.25`:
иначе Spotify может стартовать через XWayland и выглядеть как окно нормального
размера, отрисованное в низком внутреннем разрешении. Scale factor у wrapper-а
держится ниже compositor scale, чтобы Spotify был чуть крупнее базового `1`, но
не раздувался до полного `1.25` поверх масштабирования compositor-а.

`happ` не приходит из nixpkgs и установлен локальным derivation
`home/ilya/packages/happ.nix` из official GitHub release
`Happ-proxy/happ-desktop` версии `3.1.0`. Пакет использует upstream asset
`Happ.linux.x64.pkg.tar.zst` с pinned SHA-256, переносит bundled Qt desktop
application в `/nix/store`, создает wrapper `happ` и desktop entry для launcher-а.
OpenSSL добавлен в runtime dependencies намеренно: без него bundled Qt TLS
plugin падает в `cert-only` backend, а `happd` пишет `Failed to load
libssl/libcrypto` и не может выполнять HTTPS-запросы. Так как Qt OpenSSL
backend грузит эти библиотеки через `dlopen`, wrapper-ы `happ` и `happd`
добавляют OpenSSL в `LD_LIBRARY_PATH`; `happd.service` запускает именно wrapper,
а не raw binary из `share/happ/bin`.
GUI wrapper также изолирует Happ от глобальных Qt-переменных Hyprland-сессии:
сбрасывает `QT_QPA_PLATFORMTHEME`, `QT_STYLE_OVERRIDE`, `QT_PLUGIN_PATH`,
`QML2_IMPORT_PATH`, ставит `QT_QUICK_CONTROLS_STYLE=Basic` и
`QT_IM_MODULE=compose`. Это нужно, потому что Happ поставляется с bundled Qt/QML
и может падать при вводе текста или ломать QML-стили, если наследует KDE/Qt
platform theme из пользовательской сессии.
`modules/nixos/happ.nix` добавляет пакет в system profile и декларативно
запускает root-сервис `happd`, который upstream использует для TUN/VPN режима.
Это заменяет community installer-логику с `/opt/happ` и
`/etc/systemd/system/happd.service`, но не запускает чужой install script и не
пишет в `/opt` вручную.

`incy` не приходит из nixpkgs и установлен локальным derivation
`home/ilya/packages/incy.nix` из official GitHub release
`desktop-v3.3.2`. Пакет скачивает `incy-linux-x64-portable.zip`, проверяет
pinned SHA-256, распаковывает bundled Java desktop application, патчит ELF через
`autoPatchelfHook`, добавляет wrapper `incy` и `incy.desktop` для launcher-а.
Для Hyprland scale `1.25` в bundled `incy.cfg` дописывается
`-Dsun.java2d.uiScale=1.25`, иначе Compose Desktop/Skiko может выглядеть как
нормального размера окно с низким внутренним разрешением под XWayland.
`modules/nixos/incy.nix` также добавляет тот же package в system profile, чтобы
polkit видел `share/polkit-1/actions/cc.incy.vpn.policy`. Этот модуль содержит
узкое polkit-правило для `cc.incy.vpn.run-helper`: активная локальная сессия
пользователя `ilya` может запускать INCY helper без повторного ввода пароля.
Правило ограничено одним action id и не является общим passwordless sudo.
В package policy патчится с upstream `/usr/lib/incy/incy-helper-linux.sh` на
фактический store path helper-а, а `incy-helper-linux.sh`, `xray` и
`jspawnhelper` получают execute bit, потому что portable zip хранит их как
обычные `0644` файлы.
В bundled `incy.cfg` также добавлен
`-Djdk.lang.Process.launchMechanism=VFORK`, потому что helper spawn через
`pkexec` может падать с `posix_spawn failed, error: 13` в bundled JDK.
Home Manager activation удаляет stale
`~/.local/share/applications/incy.desktop`: приложение создает этот файл само,
и он может указывать на старый `/nix/store/...-incy-3.3.2`, перекрывая
актуальный desktop entry из Nix profile в Rofi.

Hyprland запускает `hyprpolkitagent` через `exec-once`. Это нужно программам,
которые вызывают `pkexec`: вместо текстового prompt-а в терминале появляется
графическое окно авторизации. INCY при этом отдельно разрешен через
`modules/nixos/incy.nix`, потому что его helper часто вызывается при включении
туннеля и не должен зависеть от KDE agent-а. Не возвращать KDE polkit agent для
Hyprland без причины: KDE Plasma остается fallback-сессией, но Hyprland не
должен зависеть от KDE agent-а для повседневной авторизации.

`tlauncher` не приходит из nixpkgs: в текущем `nixos-26.05` есть
`atlauncher` и `sqlauncher`, но нет пакета `tlauncher`. Поэтому он оформлен
локальным derivation в `home/ilya/packages/tlauncher.nix`: Nix скачивает
официальный `https://tlauncher.org/jar`, проверяет pinned SHA-256, достает
`TLauncher.jar`, делает wrapper `tlauncher` через Java и кладет валидированный
`tlauncher.desktop`, чтобы приложение появлялось в launcher-е. Wrapper перед
запуском копирует jar в writable
`$XDG_DATA_HOME/tlauncher/TLauncher.jar`, потому что стартер пытается обновлять
свой jar и не может писать в `/nix/store`.

TLauncher отдельно скачивает generic Linux JRE в
`~/.tlauncher/starter/jre_default/...`. На чистой NixOS такие бинарники падают
на stub-ld из-за отсутствующего generic dynamic linker
`/lib64/ld-linux-x86-64.so.2`, поэтому `modules/nixos/compat.nix` включает
`programs.nix-ld` с минимальным набором desktop/Java библиотек. Это нужно не
для Nix-пакетов, а именно для внешних бинарников, которые скачивает сам
TLauncher. Если upstream заменит jar на том же URL, сборка намеренно упадет на
hash mismatch; тогда нужно отдельно проверить новый файл и обновить hash.

`bitwarden-desktop` установлен через nixpkgs по явному решению пользователя.
В текущем nixpkgs пакет тянет insecure EOL `electron-39.8.10`, поэтому в
`hosts/nixos/configuration.nix` добавлено узкое исключение:

```nix
nixpkgs.config.permittedInsecurePackages = [
  "electron-39.8.10"
];
```

Не расширять этот список без отдельной причины. Если nixpkgs позже обновит
Bitwarden Desktop на безопасный Electron, это исключение нужно удалить.

Bitwarden SSH Agent ожидается по native desktop socket:

```text
/home/ilya/.bitwarden-ssh-agent.sock
```

Этот путь задан в `home.sessionVariables.SSH_AUTH_SOCK` и дополнительно
экспортируется в Fish interactive init, чтобы `ssh`, `git` и `ssh-add -L`
смотрели в Bitwarden agent. В самом Bitwarden Desktop нужно включить
`Settings -> SSH Agent -> Enable SSH agent`; после этого `ssh-add -L` должен
показывать SSH public keys из Bitwarden.

`neovim` не нужно добавлять в `home.packages`, потому что он устанавливается
через `programs.neovim`. Дублирование `neovim` уже вызывало buildEnv conflict
по `bin/nvim`.

## Команда `install`

В Fish есть функция:

```fish
install <pkgname> [pkgname...]
```

Она вызывает:

```text
/home/ilya/.local/bin/nix-install-package
```

Источник: `home/ilya/scripts/package-installer.nix`.

Что делает helper:

- принимает один или несколько пакетов;
- отказывается от option-like аргументов и подозрительных символов;
- проверяет каждый пакет против текущего flake:
  `.#nixosConfigurations.nixos.pkgs.<pkg>.name`;
- проверяет дубли внутри команды;
- проверяет очевидные дубли отдельной строкой в `.nix`;
- делает backup `home/ilya/packages/manual.nix.backup.<timestamp>`;
- добавляет все пакеты в `home/ilya/packages/manual.nix`;
- делает dry-run system build;
- при падении dry-run откатывает `manual.nix`;
- после успешного dry-run запускает `nh os switch /home/ilya/nixos-config`.

Обычный `install` из coreutils остается доступен для форм с опциями или
нетипичным количеством аргументов, потому что fish-функция отправляет такие
вызовы в `command install`.

## Hyprland

Файл: `home/ilya/hypr/hyprland.nix`.

Включено через Home Manager:

```nix
wayland.windowManager.hyprland.enable = true;
wayland.windowManager.hyprland.xwayland.enable = true;
configType = "hyprlang";
```

Переменные:

- `$mod = SUPER`
- terminal: `kitty`
- launcher: `rofi -show drun`
- file manager: `dolphin`
- browser: `/home/ilya/.local/bin/firefox-hyprland`

Autostart:

- `waybar`
- `mako`
- `awww-daemon`
- `sleep 0.5 && awww img ...` sets the wallpaper from
  `assets/wallpapers/wallhaven-2eqpzm.png`
- `hypridle`
- `wl-paste` watchers for text/image into `cliphist`
- `swayosd-server`

`swww` в текущем nixpkgs переименован в `awww`, поэтому используется `awww` и
`awww-daemon`.

Current wallpaper:

```text
assets/wallpapers/wallhaven-2eqpzm.png
```

Source: `https://wallhaven.cc/w/2eqpzm`. The file is kept in the repo and is
referenced as a Nix path from `home/ilya/hypr/hyprland.nix`, so it must remain
tracked by git for flake builds. It is a 3840x2400 PNG selected to match
Catppuccin Macchiato Blue.

Monitor scaling is set in Hyprland, not by manually increasing every app font:

```nix
monitor = [
  ",preferred,auto,1.25"
];
```

This is the current global UI scale decision for Hyprland: 25% larger UI across
the compositor. `1.10` was tried first, but Hyprland rejected it for the built-in
`eDP-1` panel and suggested `1.07`, which was too subtle for the user. The next
chosen step is the more conventional `1.25`. Avoid also adding `QT_SCALE_FACTOR`,
`GDK_SCALE`, or manual per-app font bumps unless there is a specific problem,
because that can double-scale parts of the UI and make layouts drift. KDE may
still have its own scaling behavior because it is preserved as a separate
fallback session.

For specific applications that are blurry or pixelated under this compositor
scale, prefer a per-application wrapper over global scale environment variables.
Current example: `home/ilya/packages/spotify.nix` forces Spotify to use native
Wayland/Ozone while keeping Spotify's own device scale factor at `1.10`.

XWayland bitmap scaling is disabled globally:

```nix
xwayland.force_zero_scaling = true;
```

This is intentional for the current `1.25` monitor scale. Without it, legacy
XWayland apps can be rendered at a lower internal resolution and then enlarged
by Hyprland, which makes text and UI look pixelated. With zero scaling, Hyprland
does not blur XWayland windows; individual legacy apps may look smaller if they
do not have their own HiDPI support.

Keyboard:

- layouts: `us,ru`
- switch: `Alt+Shift`

Touchpad:

- natural scroll
- tap-to-click
- tap button map `lrm`: one-finger tap/click is left, two-finger is right,
  three-finger is middle
- tap-and-drag is on
- drag lock is off
- disable while typing is off, so the touchpad keeps working while keyboard
  keys are pressed
- clickfinger behavior
- middle button emulation is off
- scroll factor `0.85`
- three/four-finger drag mode is off, so it does not conflict with workspace
  swipe gestures

The touchpad profile is tuned for everyday laptop use rather than minimalism.
`tap_and_drag` stays enabled because dragging by tap is useful, but
`drag_lock = 0` disables sticky drag-lock so the drag ends as soon as the finger
is lifted. `clickfinger_behavior` gives predictable physical clicks by finger
count, and `middle_button_emulation` is off because three-finger click/tap
already provides middle click without accidental LMB+RMB emulation.

Gestures:

- 3 fingers horizontal: workspace switching
- 4 fingers horizontal: workspace switching
- 4 fingers down: special workspace `magic`
- 4 fingers up: fullscreen
- 3 fingers pinch out: fullscreen
- 3 fingers pinch in: float
- 4 fingers pinch out: cursor zoom x2
- 4 fingers pinch in: cursor zoom reset

Workspace swipe gestures are intentionally a little conservative:
`workspace_swipe_distance = 300`, `workspace_swipe_cancel_ratio = 0.4`, and
`workspace_swipe_min_speed_to_force = 25`. This keeps the gesture responsive
while reducing accidental workspace changes from short diagonal movements.

Осторожно: Hyprland gesture syntax быстро меняется. Текущий конфиг ориентирован
на Hyprland `0.55.4` из lock-файла.

Основные бинды:

```text
SUPER+Enter       kitty
SUPER+D           rofi launcher
SUPER+Q           close active window
SUPER+M           wlogout
SUPER+E           Dolphin
SUPER+B           Firefox Hyprland wrapper
SUPER+S           special workspace magic
SUPER+Shift+S     move window to special workspace magic
SUPER+V           cliphist + rofi
Print             grim/slurp/swappy area screenshot
SUPER+F           fullscreen
SUPER+Space       floating toggle
SUPER+P           pseudo
SUPER+O           layoutmsg togglesplit
```

Workspaces:

- `SUPER+1..9,0` -> workspace 1..10
- `SUPER+Shift+1..9,0` -> move window to workspace 1..10

Mouse:

- `SUPER + left mouse` -> move window
- `SUPER + right mouse` -> resize window

Media keys:

- volume and mute are handled only by `swayosd-client`;
- brightness is handled only by `swayosd-client`;
- this avoids previous double-toggle bug where `pamixer -t` plus
  `swayosd-client --output-volume mute-toggle` immediately unmuted again.

Sleep/lock:

- `hypridle` locks after 300 seconds;
- display off after 600 seconds;
- before sleep: `loginctl lock-session`;
- after sleep: `hyprctl dispatch dpms on`;
- additional user systemd service `lock-before-sleep` locks before
  `sleep.target`.

## Firefox

System Firefox is enabled through NixOS.

Hyprland does not launch plain `firefox` from `SUPER+B`; it launches:

```text
/home/ilya/.local/bin/firefox-hyprland
```

Источник: `home/ilya/firefox/firefox.nix`.

Этот wrapper:

- создает/обновляет profile `~/.mozilla/firefox/hyprland`;
- включает `toolkit.legacyUserProfileCustomizations.stylesheets`;
- включает tabs-in-titlebar;
- пишет `chrome/userChrome.css`;
- скрывает Firefox titlebar window buttons through CSS;
- запускает `firefox --no-remote --profile ~/.mozilla/firefox/hyprland`.

Это сделано специально, чтобы в Hyprland убрать кнопки окна Firefox, но в KDE
оставить обычный Firefox с обычным profile и обычными кнопками.

Цена решения: Hyprland Firefox profile отдельный. Cookies, extensions и login
state не общие с обычным KDE Firefox profile.

## Telegram

Файл: `home/ilya/telegram/telegram.nix`.

Telegram установлен как обычный `telegram-desktop`, но пользовательский desktop
entry `org.telegram.desktop.desktop` переопределен через Home Manager. Он
запускает wrapper:

```text
/home/ilya/.local/bin/telegram-hyprland
```

Wrapper проверяет `XDG_CURRENT_DESKTOP` / `XDG_SESSION_DESKTOP`. В Hyprland он
экспортирует:

```text
QT_WAYLAND_DISABLE_WINDOWDECORATION=1
```

и затем запускает `Telegram`. Это нужно, чтобы убрать window decoration/buttons
у Telegram в Hyprland. В KDE Plasma переменная не выставляется, поэтому fallback
сессия сохраняет обычное поведение Telegram.

Так как Telegram не всегда уважает эту Qt-переменную для собственных окон, в
`home/ilya/hypr/hyprland.nix` дополнительно есть Hyprland rules:

```text
match:class ^(TelegramDesktop)$, decorate off
match:class ^(org.telegram.desktop)$, decorate off
```

Именно эти правила отключают compositor-side window decorations/buttons у
Telegram в Hyprland. KDE Plasma fallback они не затрагивают.

## Waybar

Файл: `home/ilya/waybar/waybar.nix`.

Layout:

- left: Hyprland workspaces, active window
- center: clock
- right:
  - language
  - power profile
  - CPU
  - memory
  - CPU temperature
  - tray
  - volume
  - battery
- custom power button
- power profile indicator is custom: `custom/power-profile` uses
  `/home/ilya/.local/bin/waybar-power-profile`. Click/scroll cycling is ordered
  so the previous/left step from balanced is `power-saver` and balanced is the
  top/center step. The bar shows icon-only labels: `power-saver` uses the
  10-o'clock gauge icon, `balanced` uses the 12-o'clock gauge icon.

Bar layout is tuned for current Hyprland scale `1.25`:

- `fixed-center = true`, so the clock stays visually centered even when the
  right side is wide.
- height `36`, spacing `7`, readable module padding.
- Waybar background stays close to opaque for readability: main bar alpha
  `0.92`, module background alpha `0.86`.
- Workspace buttons are explicitly reset from GTK defaults: no background
  image, no shadow, no border, stable min-width and own hover/active styles.
- active window title is capped at 42 chars.
- empty window module is visually hidden via `#window.empty`, so an empty
  title does not leave a blank pill next to workspaces.
- separate Wi-Fi and Bluetooth modules are intentionally disabled. Network and
  Bluetooth management live in tray via `nm-applet` and `blueman-applet`,
  because tray icons are enough and avoid duplicating device state in the bar.

Memory format показывает и реальные числа, и процент:

```text
 {used}G/{total}G {percentage}%
```

Power button is the rightmost item and opens:

```bash
wlogout --protocol layer-shell
```

Tray module присутствует. `nm-applet --indicator` запускается как Home Manager
user service `nm-applet.service` with `Restart=on-failure`, поэтому сетевой
индикатор должен жить в tray постоянно. `blueman-applet` запускается как Home
Manager user service `blueman-applet.service` with `Restart=on-failure`,
поэтому Bluetooth-индикатор тоже должен жить в tray постоянно.

## Wi-Fi И Bluetooth Меню

Файл: `home/ilya/scripts/network-menus.nix`.

Создает:

```text
~/.local/bin/wifi-menu
~/.local/bin/bluetooth-menu
```

Waybar больше не вызывает эти скрипты: Wi-Fi и Bluetooth управляются через
tray applets. Скрипты остаются ручными helper-командами на случай, если нужно
быстро открыть rofi-меню из терминала или вернуть бинды в будущем.

## Rofi

Файлы: `home/ilya/rofi/rofi.nix` и `home/ilya/rofi/theme.rasi`.

`SUPER+D` запускает `rofi -show drun`. Тема задается декларативно через Home
Manager и является полной Catppuccin Macchiato Blue схемой с непрозрачным темным
фоном, синим акцентом, Papirus icons и JetBrainsMono Nerd Font.

`wifi-menu`:

- использует `nmcli`;
- не делает scan при каждом открытии, чтобы меню не открывалось с большой
  задержкой;
- показывает connected state;
- умеет enable/disable Wi-Fi;
- умеет rescan отдельным пунктом;
- умеет disconnect;
- показывает numbered list сетей;
- пытается подключиться через сохраненный NetworkManager connection;
- если нужно, спрашивает пароль через rofi.

Текущий Wi-Fi menu все еще остается простым rofi-wrapper, не полноценным GUI.
Если UX снова станет неудобным, следующий шаг - заменить его отдельным более
структурированным UI, но без AGS/Eww/Quickshell это пока разумный компромисс.

`bluetooth-menu`:

- использует `bluetoothctl`;
- умеет enable/disable Bluetooth;
- scan;
- connect paired/available device;
- disconnect connected device.

## Wlogout

Файл: `home/ilya/wlogout/wlogout.nix`.

Определяет layout:

- Lock
- Logout
- Suspend
- Hibernate
- Reboot
- Shutdown

Стиль темный полупрозрачный Catppuccin Macchiato Blue. Backdrop alpha `0.54`,
buttons alpha `0.80`, hover alpha `0.88`. Первый пункт `Lock` не должен
выглядеть выделенным при открытии: CSS для `button:focus` сделан нейтральным,
а яркая подсветка оставлена для `hover`/`active`.

Иконки берутся из:

```text
/etc/profiles/per-user/ilya/share/wlogout/icons/
```

Если wlogout откроется без иконок, сначала проверить этот путь.

## Rofi

Файлы:

- `home/ilya/rofi/rofi.nix`
- `home/ilya/rofi/theme.rasi`

Используется package `pkgs.rofi`. Не использовать `rofi-wayland`: в текущем
nixpkgs он слит в `rofi`, и старое имя вызывает ошибку.

Rofi используется для:

- `SUPER+D` app launcher;
- clipboard picker;
- Wi-Fi menu;
- Bluetooth menu;
- password prompt in Wi-Fi menu.

Launcher behavior:

- Rofi history is enabled.
- `max-history-size = 100`.
- `sort = true`, `sorting-method = "fzf"`, `matching = "fuzzy"`.
- `drun-use-desktop-cache = false`.
- Goal: `SUPER+D` should prefer frequently/recently launched apps near the top
  while keeping the implementation inside native Rofi config. The desktop cache
  is intentionally disabled because it can keep stale application lists after
  Home Manager package changes; `home.activation.clearRofiDrunCache` also
  removes old `~/.cache/rofi-drun-desktop.cache` and `~/.cache/rofi3.druncache`
  on activation.

Rofi theme is opaque: `bg = #24273a`, `surface = #363a4f`.

## Kitty

Файл: `home/ilya/kitty/kitty.nix`.

Настройки:

- JetBrainsMono Nerd Font
- size 11
- Catppuccin Macchiato Blue colors
- copy on select
- `Ctrl+Shift+C` / `Ctrl+Shift+V`
- opacity `0.82`

## Fish

Файл: `home/ilya/fish/fish.nix`.

Interactive init:

- Starship
- Zoxide
- Direnv
- fzf integration if available

Aliases:

```fish
ls -> eza --icons --group-directories-first
ll -> eza -lah --icons --group-directories-first
la -> eza -la --icons --group-directories-first
cat -> bat
grep -> rg
lg -> lazygit
rebuild-test -> nh os test /home/ilya/nixos-config
rebuild-switch -> nh os switch /home/ilya/nixos-config
```

Function:

```fish
install <pkgname> [pkgname...]
```

Для нетипичных вызовов с option-like первым аргументом делает fallback в
`command install`.

## Starship

Файл: `home/ilya/starship/starship.nix`.

Минимальный prompt:

- directory
- git branch
- git status
- nix shell
- command duration
- prompt character

Palette: Catppuccin Macchiato.

## Neovim

Файл: `home/ilya/nvim/nvim.nix`.

Минимальный LazyVim-ready слой:

- line numbers
- relative numbers
- spaces, 2-space indent
- smart indent
- true color
- sign column
- system clipboard
- leader: space

Не добавлять крупный Neovim framework в этот первый слой без отдельного решения.

## Mako

Файл: `home/ilya/mako/mako.nix`.

Простые темные полупрозрачные уведомления с Catppuccin Macchiato Blue colors,
background `#24273acc`, timeout 5 секунд.

## Rebuild Workflow

Обычный путь сейчас:

```fish
rebuild-test
rebuild-switch
```

Они разворачиваются в:

```bash
nh os test /home/ilya/nixos-config
nh os switch /home/ilya/nixos-config
```

Если shell еще не подхватил aliases или flakes не активны в окружении:

```bash
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild test --flake /home/ilya/nixos-config#nixos
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake /home/ilya/nixos-config#nixos
```

Dry-run для агента перед рекомендацией switch:

```bash
nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#nixosConfigurations.nixos.config.system.build.toplevel --dry-run
```

После изменения Hyprland config:

```bash
hyprctl reload
```

После изменения Waybar:

```bash
pkill waybar
waybar &
```

После изменения session variables, GTK/Qt env или autostart лучше перелогиниться
в Hyprland.

## Rollback

Если desktop сломан, выбирать предыдущую NixOS generation в GRUB.

Если терминал доступен:

```bash
sudo nixos-rebuild switch --rollback
```

KDE Plasma в SDDM остается fallback-сессией.

## Git И Flakes

Репозиторий пока dirty. Предупреждение:

```text
warning: Git tree '/home/ilya/nixos-config' is dirty
```

не является ошибкой.

В git-репозитории Nix flakes видят только tracked файлы и файлы, добавленные
через intent-to-add. При добавлении нового файла, который импортируется flake-ом,
нужно сделать:

```bash
git add -N path/to/new-file.nix
```

Иначе evaluation может упасть с:

```text
Path '...' in the repository is not tracked by Git.
```

Перед настоящим коммитом:

```bash
git status --short
git diff --stat
git diff
```

## Known Package Name Notes

Не использовать:

- `rofi-wayland` -> использовать `rofi`
- `swww` -> использовать `awww`
- `noto-fonts-emoji` -> использовать `noto-fonts-color-emoji`
- top-level `qt5ct` -> использовать `libsForQt5.qt5ct`
- top-level `qt6ct` -> использовать `qt6Packages.qt6ct`

Не добавлять `neovim` в `home.packages`, пока включен `programs.neovim`.

## Проверочный Чеклист После Hyprland Login

1. Waybar виден.
2. `SUPER+Enter` открывает Kitty.
3. `SUPER+D` открывает rofi launcher.
4. `SUPER+B` открывает Firefox Hyprland profile без Firefox window buttons.
5. `SUPER+E` открывает Dolphin.
6. Alt+Shift переключает `us`/`ru`, индикатор языка обновляется.
7. Volume/mute keys работают без double-toggle.
8. Brightness keys работают.
9. `Print` запускает screenshot через grim/slurp/swappy.
10. `SUPER+V` открывает clipboard history.
11. Клик по Wi-Fi в Waybar открывает `wifi-menu`.
12. Клик по Bluetooth в Waybar открывает `bluetooth-menu`.
13. Крайняя правая power button открывает wlogout.
14. Закрытие крышки после rebuild должно отправлять ноут в suspend.
15. При sleep сессия должна блокироваться.
16. KDE Plasma все еще доступна в SDDM.

## Рекомендации Для Следующих Изменений

Продолжать маленькими шагами. После каждого изменения:

1. Изменить нужные `.nix` файлы.
2. Если добавлен новый импортируемый файл, выполнить `git add -N`.
3. Обновить этот `NOTES.md` по месту.
4. Запустить dry-run build.
5. В финальном ответе сказать, что изменено и как применить.

Не делать крупный неконтролируемый diff без необходимости.
