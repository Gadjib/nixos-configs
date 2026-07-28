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

При установке каждой новой графической программы в том же изменении нужно
добавить для нее отдельную иконку в `hyprland/workspaces.window-rewrite` в
`home/ilya/waybar/waybar.nix`. Нужно учитывать реальный Wayland `app_id` и/или
XWayland `WM_CLASS`; если возможны несколько вариантов класса, они объединяются
одним regex. Иконка должна существовать в используемом Nerd Font. Установка GUI
программы не считается завершенной, пока mapping не добавлен. Если точный класс
невозможно узнать до первого запуска, добавляется mapping для ожидаемого класса,
а после применения конфигурации класс проверяется через `hyprctl clients` и при
необходимости исправляется. Правило не относится к CLI-программам, библиотекам,
драйверам и фоновым сервисам, которые не создают окна.

Перед тем как предлагать пользователю выполнить `rebuild-switch` или
эквивалентный `nh os switch /home/ilya/nixos-config`, нужно сначала закоммитить
актуальное состояние репозитория. Идея: любой switch должен иметь понятную
точку отката в Git. Исключение допустимо только если пользователь явно просит не
коммитить или если commit технически невозможен; в таком случае нужно сказать об
этом прямо до команды switch.

Агент не запускает `rebuild-test`, `rebuild-switch`, `nh os test`,
`nh os switch`, `nixos-rebuild` и другие команды, которые реально собирают или
активируют конфигурацию, если пользователь отдельно и явно не попросил об этом в
текущей задаче. Обычный workflow агента: изменить конфиг и документацию,
выполнить проверки синтаксиса, evaluation, warnings и `nix build --dry-run`,
закоммитить изменения, затем подробно сообщить пользователю, что изменено и
какой объем сборки ожидается. Пользователь читает изменения и сам запускает
пересборку системы.

Push в remote не делать после каждого commit. Нормальный режим: пушить пачкой
примерно каждые 5 локальных commit или если с предыдущего push прошло больше
суток. Если пользователь явно просит push, push делать сразу.

## Машина

- Hostname: `thinkpad-nix`
- User: `ilya`
- Архитектура: `x86_64-linux`
- Time zone: `Europe/Moscow`
- NixOS state version: `26.05`
- Home Manager state version: `26.05`
- Flake input Nixpkgs: `github:NixOS/nixpkgs/nixos-26.05`
- Flake input Nixpkgs unstable: `github:NixOS/nixpkgs/nixos-unstable`
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
nixosConfigurations.thinkpad-nix
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
│   ├── nix.nix
│   ├── packages.nix
│   ├── removable-media.nix
│   ├── compat.nix
│   ├── smb.nix
│   ├── swap.nix
│   └── users.nix
└── home/ilya/
    ├── appearance.nix
    ├── home.nix
    ├── firefox/firefox.nix
    ├── fish/fish.nix
    ├── hypr/hyprland.nix
    ├── kitty/kitty.nix
    ├── mako/mako.nix
    ├── nvim/nvim.nix
    ├── packages/manual.nix
    ├── packages/spotify.nix
    ├── rofi/rofi.nix
    ├── rofi/theme.rasi
    ├── scripts/network-menus.nix
    ├── scripts/package-installer.nix
    ├── starship/starship.nix
    ├── vscode/vscode.nix
    ├── waybar/waybar.nix
    └── wlogout/wlogout.nix
```

`docs/` содержит справочные заметки и cheatsheets. Они полезны пользователю, но
`NOTES.md` остается главным файлом для агентского контекста.

`home/ilya/packages/manual.nix.backup.*` - backup-файлы, созданные helper-ом
`nix-install`. Они не являются активным конфигом.

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
- `xdg-desktop-portal-kde`
- `xdg-desktop-portal-gtk`
- Hyprland portal preference: `default=hyprland;kde;gtk`
- `org.freedesktop.impl.portal.FileChooser` explicitly uses `kde`

Portal backend list and the Hyprland preference are declared in both the NixOS
module and Home Manager. This duplication is required by the current Home
Manager Hyprland module: it enables `xdg.portal` for the user and exports
`NIX_XDG_DESKTOP_PORTAL_DIR` pointing at the per-user profile. Therefore the
Home Manager profile must contain the KDE and GTK fallback descriptors in
addition to Hyprland's portal. KDE provides the native themed `FileChooser`;
Hyprland remains first for compositor-specific ScreenCast/Screenshot
interfaces, and GTK remains the final fallback.

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

USB removable media:

- `modules/nixos/removable-media.nix` enables `udisks2` explicitly.
- A udev rule starts `usb-automount@<device>.service` for each USB block device
  with a recognized filesystem.
- Filesystems mount immediately below `/mnt/<label>`; unlabeled filesystems use
  `/mnt/<device>`. If that directory already exists, the device name is added
  to avoid hiding an existing directory.
- FAT, exFAT, and NTFS mounts use `ilya` ownership. All automatic mounts use
  `nosuid,nodev,noexec`.
- The service stays bound to the kernel device and unmounts/removes its
  mountpoint when the device disappears.
- Success and failure are sent to the active user D-Bus notification service,
  so Mako shows the mount path or the mount error. Errors are also retained in
  `journalctl -u 'usb-automount@*.service'`.

SMB mount:

- `modules/nixos/smb.nix` mounts `//192.168.0.10/home` at `/vault` using
  the standard SMB port.
- It uses `x-systemd.automount`, `noauto`, `_netdev`, `nofail`, so boot should
  not block if the NAS is offline.
- The mount requires `home-smb-available.service`. On SSID `0xDEADBEEF48` the
  preflight immediately permits the normal CIFS attempt without a ping. In
  every other network session it sends exactly one one-second ping to
  `192.168.0.10`, bound to the active Wi-Fi interface when present.
- The non-home result is cached in `/run/home-smb-preflight/current`, keyed by
  NetworkManager's `ActiveConnection` id. A failed probe blocks all further
  probes and CIFS attempts for that connection session; reconnecting or
  changing networks produces a new id and permits one new ping.
- tmpfiles creates `/vault` and removes the obsolete `/mnt/home` directory only
  when the old path is empty.
- Auth uses `/etc/samba/vault.credentials`, which must stay outside git.
  It should contain `username=...`, `password=...`, and optionally
  `domain=WORKGROUP`.
- `cifs-utils` is installed system-wide for `mount.cifs` diagnostics.

Swap:

- `modules/nixos/swap.nix` declares `/swapfile` through `swapDevices`.
- Size is `16 * 1024` MiB, exactly 16 GiB.
- The root filesystem is ext4, so no Btrfs-specific swapfile handling is
  needed. NixOS creates and initializes a missing file through its generated
  `mkswap-*.service`, then activates the corresponding systemd swap unit.
- Hibernation/resume is not configured; this is regular memory-pressure swap.

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

Networking and DNS:

- `networking.networkmanager.enable = true`
- `networking.enableIPv6 = false`
- `services.resolved.enable = true`

`systemd-resolved` is enabled intentionally. On NixOS, enabling
`services.resolved` makes `/etc/resolv.conf` point at
`/run/systemd/resolve/stub-resolv.conf`, disables legacy `resolvconf`, and asks
NetworkManager to use `systemd-resolved`. This matters for VPN/TUN clients such
as Happ/sing-box: IP routing through TUN can work while domain resolution fails
if per-link DNS is not delivered to a resolver that understands systemd link
DNS settings.

IPv6 is disabled intentionally for now. The Wi-Fi network advertises IPv6 routes
and DNS returns AAAA records, but real IPv6 TCP connections stay in `SYN-SENT`
and time out. GUI applications such as Firefox, Telegram, Discord, and Happ can
then appear broken even while IPv4 `curl` and `ping` work. Keep IPv6 disabled
until the upstream network or VPN path has working IPv6; then this can be
revisited.
`networking.enableIPv6 = false` sets global/default sysctls, but NetworkManager
can still leave IPv6 enabled on an already active interface. A small
NetworkManager dispatcher script therefore also sets
`net.ipv6.conf.<interface>.disable_ipv6=1` and flushes IPv6 addresses/routes for
non-loopback interfaces when they come up. This avoids declaring Wi-Fi
connection secrets in Nix just to change `ipv6.method`. The dispatcher is not
tied to a particular SSID or NetworkManager profile; it receives the interface
name from NetworkManager and works for any Wi-Fi network using that interface.

Expected post-switch checks:

```text
readlink -f /etc/resolv.conf
curl -4 -I https://google.com
curl -6 -I --max-time 8 https://google.com
resolvectl query google.com
resolvectl status
```

`readlink` should resolve to `/run/systemd/resolve/stub-resolv.conf`.
The IPv6 curl check is expected to fail or return no route while IPv6 is
disabled; applications should then use IPv4 immediately instead of hanging on
broken IPv6 attempts.

### `modules/nixos/packages.nix`

Системные программы: Firefox и Steam включены через собственные NixOS-модули.
Steam package sets `GLOBIGNORE=/vault` in `extraPreBwrapCmds` so the generated
FHS wrapper does not stat or bind the root-level SMB automount while enumerating
host directories. This prevents an unavailable `/vault` from aborting Steam's
`bubblewrap` startup; all other host directories retain the standard Nixpkgs
Steam behavior. `dotglob` is disabled again after assigning `GLOBIGNORE` to
avoid changing which hidden root entries the wrapper enumerates.
В `environment.systemPackages` находятся Kitty, Dolphin, Kate, Thunar,
`nwg-look`, `qt5ct`, `qt6ct`, Papirus, Bibata, pavucontrol, blueman,
brightness/audio helpers, hardware/network diagnostics including `efibootmgr`
и `os-prober`, compiler/dev tools. `codex` берется из отдельного
`nixpkgs-unstable` input, чтобы обновлять CLI точечно и не переводить всю
систему на unstable.

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
- VS Code и декларативных extensions/settings
- Waybar
- Wlogout

Home Manager также задает session variables:

- `EDITOR = "nvim"`
- `TERMINAL = "kitty"`
- `BROWSER = "/home/ilya/.local/bin/firefox-hyprland"`
- cursor theme/size из единого `home/ilya/appearance.nix`
- GTK dark preference
- Qt platform theme `kde`
- Qt Quick Controls style `org.kde.desktop`
- `XDG_CURRENT_DESKTOP = "Hyprland"`
- `XDG_SESSION_DESKTOP = "Hyprland"`

Глобальные параметры оформления собраны в `home/ilya/appearance.nix`: scale,
cursor theme/package/size, icon theme/package, UI и monospace fonts, GTK theme
и Qt/KDE theme names. Остальные модули импортируют этот файл, поэтому смена
курсора в нем автоматически обновляет Home Manager session variables,
Hyprland/Hyprcursor, XWayland/Xresources, GTK, dconf и compatibility links
`~/.icons`/`~/.local/share/icons`. Cursor size is `30`, matching the enlarged
Hyprland scale. Rofi, Mako, qt5ct/qt6ct и `kdeglobals` также получают общие
имена и шрифты из `appearance.nix`.

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
  reliably expand the scheme name by themselves. Home Manager generates the
  declarative source as `~/.config/.home-manager-kdeglobals`, then
  `installWritableKdeglobals` copies it after `linkGeneration` to a regular
  writable `~/.config/kdeglobals` with mode `0600`. Do not manage
  `kdeglobals` as a direct `xdg.configFile` symlink: KDE's `KConfig` resolves
  that symlink into `/nix/store`, fails to create `hm_kdeglobals.lock`, and Qt
  applications such as Telegram can abort when opening a file chooser.
- GTK4 theme files are explicitly linked from Catppuccin into
  `~/.config/gtk-4.0/gtk.css`, `gtk-dark.css`, and `assets`.
- Kitty, Rofi, Mako, Waybar, Wlogout, Starship, Hyprland borders and
  Hyprlock use the same Macchiato palette directly in their own modules.

XDG default applications are managed declaratively in `home/ilya/home.nix` via
`xdg.mimeApps`. This is intentional because runtime `~/.config/mimeapps.list`
previously made images open in Firefox from Yazi.

Current default app policy:

- web links and HTML: `firefox-hyprland.desktop`.
- images: `org.kde.gwenview.desktop`.
- video/audio: `vlc.desktop`.
- PDFs and document-like files: Okular desktop entries.
- archives: `org.kde.ark.desktop`.
- directories: `org.kde.dolphin.desktop`.
- plain text: `org.kde.kate.desktop`.
- code/config formats: `code.desktop`.

`firefox-hyprland.desktop` intentionally does not advertise image MIME types.
It is the common entry point for Hyprland browser keybindings and web links,
not a general image viewer.

## Пользовательские Пакеты

Базовые Home Manager пакеты лежат в `home/ilya/home.nix`.

Туда входят Hyprland stack, CLI tools, Bitwarden Desktop, Telegram,
`networkmanagerapplet`, Catppuccin GTK/KDE themes, `direnv`, `nix-direnv`,
`lazygit`, `delta`, `gh`, `net-tools` (включая `ifconfig`) и прочее.

Ручные пакеты, добавленные командой `nix-install`, лежат отдельно:

```text
home/ilya/packages/manual.nix
```

Актуальный список намеренно не дублируется в документации: источником истины
служит сам `home/ilya/packages/manual.nix`. Это позволяет helper-у добавлять
пакеты без превращения `NOTES.md` в рассинхронизированный второй package list.

Obsidian установлен обычным пакетом `pkgs.obsidian` из закрепленного nixpkgs;
отдельный wrapper или системный модуль для него не используется.

LibreOffice установлен как `pkgs.libreoffice-qt6`, чтобы использовать уже
настроенную KDE/Qt6 integration в Hyprland. Declarative MIME associations
направляют Word/RTF/ODT в Writer, Excel/ODS в Calc и PowerPoint/ODP в Impress.
PDF и EPUB по-прежнему открываются в Okular.

VS Code больше не является строкой в `packages/manual.nix`: им владеет
`home/ilya/vscode/vscode.nix` через `programs.vscode`. Модуль устанавливает
`shd101wyy.markdown-preview-enhanced`, задает
`markdown-preview-enhanced.previewMode = "Previews Only"` и ассоциацию
`"*.md" = "markdown-preview-enhanced"` в `workbench.editorAssociations`.
Это открывает каждый Markdown-файл сразу в отдельном MPE custom-editor preview,
поэтому preview разных файлов могут оставаться в нескольких вкладках. Built-in
view type `vscode.markdown.preview.editor` намеренно не используется.

Spotify установлен через локальный wrapper `home/ilya/packages/spotify.nix`.
Он запускает Chromium frontend через native Wayland/Ozone и задаёт
`--force-device-scale-factor=1.10`, чтобы интерфейс оставался чётким при
Hyprland scale `1.25`, а не размывался при масштабировании XWayland. Desktop
entry также направлен на wrapped binary, поэтому тот же режим используется при
запуске из Rofi.

Нативный Linux-клиент Half-Life 2 получает декларативный stability profile из
`home/ilya/packages/hl2.nix`. Два coredump от 2026-07-28 упали с одинаковым
стеком `materialsystem.so -> shaderapidx9.so -> engine.so`, а перед падением
OpenGL backend создавал 4x MSAA shaders с несовпадающей centroid mask. Поэтому
`hl2_complete/cfg/autoexec.cfg` принудительно включает синхронный
`mat_queue_mode 0`, отключает вспомогательные render threads и MSAA, оставляет
VSync и ограничивает частоту до 60 FPS. Управляемый
`hl2/videoconfig_linux.cfg` также отключает 4x MSAA до инициализации OpenGL,
сохраняя fullscreen `1920x1200` и остальные текущие параметры. Это профиль для
нативного `hl2_linux`; Proton/Wine не используется, сохранения и Steam cache
не изменяются.

После смены hostname с `nixos` на `thinkpad-nix` пришлось один раз удалить
`~/.cache/spotify/SingletonCookie`, `SingletonLock` и `SingletonSocket`: они
остались с lock target `nixos-51010`, из-за чего новые запуски из
Rofi молча завершались с кодом 1. Это runtime cleanup, а не постоянная часть
конфигурации.

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
`QML2_IMPORT_PATH`, ставит `QT_QPA_PLATFORM=wayland;xcb`,
`QT_QUICK_CONTROLS_STYLE=Basic` и `QT_IM_MODULE=compose`. Wayland выбирается
первым, чтобы touchpad scrolling и input semantics совпадали с остальными
нативными приложениями Hyprland; `xcb` остается fallback для X11-сессий.
Bundled Happ содержит рабочий `libqwayland.so` со всеми runtime dependencies.
Изоляция остальных Qt variables нужна, потому что Happ поставляется с bundled
Qt/QML и может падать при вводе текста или ломать QML-стили, если наследует
KDE/Qt platform theme из пользовательской сессии.
Wrapper `happ` не читает и не меняет пользовательский config перед запуском GUI.
Happ сам управляет своим TUN, DNS и routing state. Раньше в конфигурации были
самодельные вмешательства:
wrapper редактировал sing-box JSON, а отдельный root-сервис пытался чинить
маршрутизацию для процессов Happ/Xray. Ручная проверка показала, что именно эти
вмешательства ломали обычный интернет после подключения VPN, поэтому они
удалены. Важное правило для следующих агентов: не возвращать автоматическое
редактирование пользовательского Happ config и не добавлять собственный
policy-routing слой, пока штатный Happ работает без него.
`modules/nixos/happ.nix` добавляет пакет в system profile и декларативно
запускает root-сервис `happd`, который upstream использует для TUN/VPN режима.
Это заменяет community installer-логику с `/opt/happ` и
`/etc/systemd/system/happd.service`, но не запускает чужой install script и не
пишет в `/opt` вручную.
`happd.service` intentionally starts after `network-online.target` and
`systemd-resolved.service`. Happ can recover from early DNS failures, but
starting the daemon after the resolver is ready avoids boot-time
`HostNotFound` noise and makes TUN/DNS setup less timing-sensitive.
Этот же модуль создает compatibility symlink для HWID:
`/var/lib/dbus/machine-id -> /etc/machine-id` через `systemd.tmpfiles.rules`.
Happ получает machine id через Qt `machineUniqueId()`, а на NixOS с
`dbus-broker` legacy path `/var/lib/dbus/machine-id` может отсутствовать. Без
этого сервер подписки может видеть пустой HWID и возвращать заглушки вроде
`App not supported or HWID disabled in settings` вместо реальных узлов.

Hyprland запускает `hyprpolkitagent` через `exec-once`. Это нужно программам,
которые вызывают `pkexec`: вместо текстового prompt-а в терминале появляется
графическое окно авторизации. Не возвращать KDE polkit agent для Hyprland без
причины: KDE Plasma остается fallback-сессией, но Hyprland не должен зависеть
от KDE agent-а для повседневной авторизации.

`tlauncher` не приходит из nixpkgs: в текущем `nixos-26.05` есть
`atlauncher` и `sqlauncher`, но нет пакета `tlauncher`. Поэтому он оформлен
локальным derivation в `home/ilya/packages/tlauncher.nix`: Nix скачивает
официальный `https://tlauncher.org/jar`, проверяет pinned SHA-256, достает
`TLauncher.jar`, делает wrapper `tlauncher` через Java и кладет валидированный
`tlauncher.desktop`, чтобы приложение появлялось в launcher-е. Wrapper перед
первым запуском копирует jar в writable
`$XDG_DATA_HOME/tlauncher/TLauncher.jar`, потому что стартер обновляет свой jar
и не может писать в `/nix/store`. Копирование выполняется только если runtime
jar отсутствует: сравнивать его со store jar и восстанавливать при отличии
нельзя. Иначе wrapper откатывает штатное self-update, TLauncher при каждом
старте снова показывает dialog о замене launcher-а и запускает второй process.
Если runtime jar поврежден и нужен чистый seed, его можно удалить вручную при
полностью закрытом TLauncher; следующий запуск восстановит файл из Nix store.

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

## Команда `nix-install`

В Fish есть функция:

```fish
nix-install <pkgname> [pkgname...]
```

Она вызывает:

```text
/home/ilya/.local/bin/nix-install-package
```

Источник: `home/ilya/scripts/package-installer.nix`.

Что делает helper:

- принимает один или несколько пакетов;
- требует полностью чистый Git worktree до начала изменений;
- отказывается от option-like аргументов и подозрительных символов;
- проверяет каждый пакет против текущего flake:
  `.#nixosConfigurations.thinkpad-nix.pkgs.<pkg>.name`;
- проверяет дубли внутри команды;
- проверяет очевидные дубли отдельной строкой в `.nix`;
- делает backup `home/ilya/packages/manual.nix.backup.<timestamp>`;
- добавляет все пакеты в `home/ilya/packages/manual.nix`;
- делает dry-run system build;
- при падении dry-run откатывает `manual.nix`;
- проверяет, что в worktree изменился только `manual.nix`;
- создает отдельный Git commit с новым package list;
- только после успешного commit запускает `nh os switch`.

Обычный `install` из coreutils больше не переопределяется Fish-функцией и всегда
остается доступен под своим стандартным именем.

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

Firefox windows are assigned to workspace 2 by a Hyprland window rule matching
class `firefox`.

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

The current Wayland UI scale is `1.25`, restoring the established size for
native Wayland applications and desktop components. Avoid also adding global
`QT_SCALE_FACTOR`, `GDK_SCALE`, or manual font bumps, because that can
double-scale parts of the UI. KDE may still have its own scaling behavior
because it is preserved as a separate fallback session.

XWayland is intentionally kept at scale `1` independently of the Wayland scale:

```nix
xwayland = {
  force_zero_scaling = true;
  use_nearest_neighbor = false;
};
```

`force_zero_scaling` makes XWayland publish the physical `1920x1200` mode
instead of the Wayland logical `1536x960` geometry. X11 games such as native
Linux Half-Life 2 can therefore select and render at the panel's physical
resolution without compositor enlargement. Legacy X11 desktop applications
that do not implement their own HiDPI scaling will appear smaller than Wayland
applications. Cursor theme and size still come from `appearance.nix` through
both XCursor and Hyprcursor settings.

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

Do not normalize all touchpad option names to underscores. In the current
Hyprland version, `tap-to-click` and `tap-and-drag` must stay hyphenated in the
generated config; `tap_to_click` and `tap_and_drag` are rejected at runtime.

Gestures:

- 3 fingers horizontal: workspace switching
- 4 fingers horizontal: workspace switching
- 4 fingers down: special workspace `magic`
- 4 fingers up: fullscreen
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
- `SUPER+CTRL+1..9,0` -> workspace 11..20
- `SUPER+CTRL+SHIFT+1..9,0` -> move window to workspace 11..20
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
- запускает `firefox --profile ~/.mozilla/firefox/hyprland`.

HTTP/HTTPS links, HTML files, `BROWSER` and `SUPER+B` all use the same wrapper.
Firefox remoting is left enabled, so a new URL is handed to an already running
Hyprland-profile instance instead of starting another browser instance. When
the wrapper receives a URL and finds an existing Firefox window through
`hyprctl -j clients`, it then runs `focuswindow class:^(firefox)$`; Hyprland
therefore switches to workspace 2 and focuses Firefox after opening the link.

Это сделано специально, чтобы в Hyprland убрать кнопки окна Firefox, но в KDE
оставить обычный Firefox с обычным profile и обычными кнопками.

Цена решения: Hyprland Firefox profile отдельный. Cookies, extensions и login
state не общие с обычным KDE Firefox profile.

## Telegram

Telegram установлен напрямую как `pkgs.telegram-desktop`. Для него нет
локального wrapper-а, дополнительных environment variables, подмены desktop
entry или DBus service, MIME association и Hyprland window rules. Приложение
запускается с полностью upstream-конфигурацией пакета.

Пользовательские данные Telegram в `~/.local/share/TelegramDesktop`, кэш и
прочие runtime-файлы декларативной конфигурацией не управляются и не удаляются.

## Waybar

Файл: `home/ilya/waybar/waybar.nix`.

Layout:

- left: Hyprland workspaces, active window
- center: empty
- right:
  - language
  - power profile
  - CPU
  - memory
  - CPU temperature
  - tray
  - volume
  - battery
  - date and time in `dd.mm.yy HH:MM` format
  - custom power button
- power profile indicator is custom: `custom/power-profile` uses
  `/home/ilya/.local/bin/waybar-power-profile`. Click/scroll cycling is ordered
  so the previous/left step from balanced is `power-saver` and balanced is the
  top/center step. The bar shows icon-only labels: `power-saver` uses the
  10-o'clock gauge icon, `balanced` uses the 12-o'clock gauge icon.

Bar layout is tuned for the current Hyprland scale `1.25`:

- `fixed-center = false`; the center is intentionally empty and date/time sits
  on the right between battery and power in `dd.mm.yy HH:MM` format.
- height `36`, spacing `7`, readable module padding.
- Waybar background stays close to opaque for readability: main bar alpha
  `0.92`, module background alpha `0.86`.
- Workspace buttons are explicitly reset from GTK defaults: no background
  image, no shadow, no border, compact `22px` min-width, reduced horizontal
  padding/margins and own hover/active styles.
- Workspace labels use `{name}{windows:.2}`. Waybar keeps its internal window
  list in opening order; every rewrite value consists of one leading space and
  one Nerd Font icon, so the string precision keeps only the first opened
  window. This uses the native `hyprland/workspaces` module without polling,
  helper processes or workspace renaming. Known application classes have
  dedicated icons and unmatched classes use a generic window icon.
- Every newly installed GUI application must add its class and dedicated icon
  to this `window-rewrite` table in the same change, as required by the
  repository workflow above.
- OpenMW uses the controller icon for `openmw`, `openmw-launcher`, `openmw-cs`
  and reverse-DNS `org.openmw.*` window identifiers.
- active window title is capped at 42 chars.
- empty window module is visually hidden via the Waybar-supported selector
  `window#waybar.empty #window`, so an empty title does not leave a blank pill
  next to workspaces.
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

- Oh My Fish from `pkgs.oh-my-fish`
- Agnoster theme pinned from the official `oh-my-fish/theme-agnoster` repository
- Zoxide
- Direnv
- fzf integration if available

Oh My Fish is loaded declaratively from the Nix store through `OMF_PATH`.
Home Manager writes `~/.config/omf/theme` with `agnoster` and links the pinned
theme source at `~/.config/omf/themes/agnoster`. Do not run `omf install` or
`omf theme` for declaratively managed packages/themes; change
`home/ilya/fish/fish.nix` instead. The `omf` command remains available for
inspection and diagnostics.

Upstream Agnoster scans every `/nix/store/...` entry in `$PATH` to detect
`nix shell`. On NixOS that misdetects the normal system environment and creates
a huge `nix[binutils-wrapper ...]` segment. `fish.nix` overrides only
`prompt_virtual_env`: the standard Agnoster directory segment stays visible,
Conda/Python environments still work, and a Nix segment is shown only when
`IN_NIX_SHELL` is actually set. `fish_prompt.fish` is sourced explicitly before
the override; without this ordering, Fish autoloads the upstream theme on the
first prompt render and silently replaces the override.

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
nix-install <pkgname> [pkgname...]
```

Стандартная команда coreutils `install` не переопределяется.

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

Starship остается установленным и его config продолжает генерироваться, но
`enableFishIntegration = false`: активный Fish prompt принадлежит теме Agnoster,
поэтому Starship не переопределяет `fish_prompt`.

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
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild test --flake /home/ilya/nixos-config#thinkpad-nix
sudo env NIX_CONFIG="experimental-features = nix-command flakes" nixos-rebuild switch --flake /home/ilya/nixos-config#thinkpad-nix
```

Агент ограничивается evaluation и dry-run; фактические `test` и `switch`
выполняет пользователь, кроме случаев, когда он отдельно и явно попросил агента
запустить их в текущей задаче. Dry-run перед рекомендацией switch:

```bash
nix --extra-experimental-features nix-command --extra-experimental-features flakes build .#nixosConfigurations.thinkpad-nix.config.system.build.toplevel --dry-run
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
11. Индикатор NetworkManager присутствует в tray.
12. Индикатор Bluetooth присутствует в tray.
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
