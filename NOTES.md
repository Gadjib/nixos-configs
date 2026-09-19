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

При диагностике типичной или потенциально известной проблемы сначала нужно
сделать короткий целевой поиск в интернете по точному сочетанию компонентов и
симптомов (например, `NixOS + Hyprland + Dolphin + empty Open With`). Сначала
проверяются официальная документация, upstream issue tracker и обсуждения
NixOS; найденное решение затем сверяется с локальной версией и конфигурацией.
Только если готового решения нет, оно не подходит или не подтверждается
минимальной проверкой, переходить к подробному исследованию D-Bus, coredump,
исходников и runtime-экспериментам. Не расходовать время и токены пользователя
на низкоуровневую диагностику до поиска известных решений и не перезапускать
компоненты рабочего сеанса, когда исправление можно проверить после обычного
rebuild и нового входа в систему.

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
- Telegram has its own `nixpkgs-telegram` input on `nixos-unstable`, pinned
  independently of Bitwarden and the base system.
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
│   ├── throne.nix
│   ├── nix.nix
│   ├── packages.nix
│   ├── removable-media.nix
│   ├── compat.nix
│   ├── smb.nix
│   ├── swap.nix
│   └── users.nix
└── home/ilya/
    ├── appearance.nix
    ├── desktop-session-isolation.nix
    ├── home.nix
    ├── firefox/firefox.nix
    ├── fish/fish.nix
    ├── hypr/hyprland.nix
    ├── kitty/kitty.nix
    ├── mako/mako.nix
    ├── nvim/nvim.nix
    ├── packages/manual.nix
    ├── packages/spotify.nix
    ├── removable-media.nix
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

Fingerprint configuration in `modules/nixos/desktop.nix`:

Сканер Synaptics Prometheus `06cb:00fc` в ThinkPad X1 Carbon Gen 10
поддерживается штатным `libfprint`, поэтому модуль включает
`services.fprintd` без TOD/проприетарного драйвера.

Отпечаток используется для polkit (включая Bitwarden system
authentication), KDE lock screen через создаваемый Plasma PAM service
`kde-fingerprint` и Hyprlock. Для `sudo` fingerprint PAM отключен,
чтобы `sudo` сразу запрашивал пароль без ожидания таймаута
`pam_fprintd`. Hyprlock обращается к
`fprintd` напрямую параллельно парольному PAM, поэтому
`hyprlock.fprintAuth = false` намеренно исключает двойной захват
сканера. Пароль везде остается fallback-способом.

SDDM делегирует authentication в PAM substack `login`, поэтому
fingerprint включен как `login.fprintAuth = true`; отдельное
`sddm.fprintAuth` остается `false`, потому что SDDM service использует
`useDefaultRules = false` и сам это правило не читает. Для fingerprint
login нужно выбрать user, оставить password пустым, нажать
Enter и приложить палец. Password authentication остается fallback;
`pam_fprintd` ограничен `timeout=10` и `max-tries=3`, чтобы SDDM не
ждал стандартные 30 секунд перед password fallback. Вход по
отпечатку не передает password в `pam_kwallet`, поэтому KDE Wallet
после такого login может отдельно запросить пароль.

Bitwarden установлен через Home Manager, а polkit не
сканирует user profile, поэтому модуль отдельно выводит в
system profile только `com.bitwarden.Bitwarden.policy`, без второго
desktop entry.

Отпечатки не хранятся в Git/Nix store. После первого switch
пользователь записывает и проверяет палец интерактивно:

```text
fprintd-enroll -f right-index-finger
fprintd-verify
```

Шаблоны хранятся `fprintd` в `/var/lib/fprint`; для удаления
всех отпечатков текущего пользователя используется
`fprintd-delete`.

USB removable media:

- `modules/nixos/removable-media.nix` enables `udisks2` explicitly.
- `home/ilya/removable-media.nix` enables the user-level `udiskie` daemon only
  for `hyprland-session.target`, with automounting, notifications and an
  auto-hiding tray icon. Plasma uses its native device notifier and KDED device
  automounter instead, so the two desktop environments never race each other.
  UDisks mounts
  removable filesystems below `/run/media/ilya/<label>` and owns the complete
  mount/unmount/eject lifecycle, so Dolphin and the tray can safely eject a
  device without treating it as somebody else's root mount.
- Automatic mounts request `nosuid,nodev,noexec` through udiskie. Hybrid ISO
  images and multi-partition drives are handled by UDisks/udiskie instead of
  racing separate whole-disk and partition systemd units.
- The udiskie user service uses `Restart=on-failure`, so an unexpected process
  crash does not silently disable automounting for the rest of the session.
  It deliberately has no ordering dependency on `tray.target`: both udiskie
  and Waybar belong to `hyprland-session.target`, and ordering udiskie after
  the tray would form a systemd target cycle. The `auto` status notifier can
  register before Waybar and appears when the tray becomes available.
- Home Manager manages `~/media` as an out-of-store symlink to
  `/run/media/ilya`, usable in both Hyprland and Plasma. UDisks creates the
  target as needed; before the first mount it may not exist.
- There are no custom mount event hooks, per-device compatibility links or
  link-state files. Udiskie startup no longer depends on a link-sync script.
- `/mnt` has normal `root:root` ownership and mode `0755`; the separate
  Windows mount `/mnt/win_c` remains configured in `modules/nixos/windows.nix`.
- At migration, the old service's stop hook can remove links it still tracks.
  No blanket cleanup of `/mnt` is performed. Inspection before this change
  found no top-level symlinks there.

Windows partition:

- The internal NTFS Windows data partition with UUID `32566001565FC3EF` is
  exposed at `/mnt/win_c` through `modules/nixos/windows.nix`. A systemd
  automount starts during boot and mounts the partition transparently on first
  access; after that it stays mounted.
- It uses the kernel `ntfs3` driver with read/write access owned by
  `ilya:users`; `windows_names` rejects Linux filenames that Windows cannot
  represent.
- `noauto`, `nofail`, `x-systemd.automount` and a five-second device timeout
  keep an unavailable, dirty or hibernated Windows partition from blocking
  NixOS boot or `nh test`. Access still fails until Windows repairs a dirty
  volume. Such a partition is intentionally not force-mounted because that
  could damage it.

SMB mounts:

- `modules/nixos/smb.nix` defines five independent native systemd mount units:
  `/vault/home`, `/vault/Downloads`, `/vault/music`, `/vault/video`, `/vault/Store`.
  Each maps to the identically named share at `//192.168.0.10/`; case matters.
  `/vault` itself is now a local directory, not the old `home` share mount.
  Existing paths into that share must be updated from `/vault/...` to
  `/vault/home/...`. No remote files are moved.
- Only an active Wi-Fi SSID starting with the exact, case-sensitive prefix
  `0xDEADBEEF` permits automatic mounting. Merely seeing such an AP nearby is
  insufficient. Ethernet-only and other Wi-Fi networks do not permit mounting.
- `home-smb-network.sh` reads NetworkManager's cached ACTIVE/SSID list with
  `--rescan no`. There are no pings, port probes, availability cache, periodic
  retries, or access-triggered automounts outside the home network.
- NetworkManager up/down/dhcp4-change/reapply events queue the short
  `home-smb-refresh.service`; the same service runs at boot/activation. It reads
  current network state rather than trusting an old event, then asynchronously
  starts or stops `home-smb.target` and all five mount units. Failed mounts can
  retry on the next qualifying event. Dispatcher execution never waits for CIFS.
- All mount units require a fresh `home-smb-network-allowed.service` check before
  starting, including manual starts. Each mount/unmount has a 10-second timeout.
  One unavailable share does not prevent mounting the others.
- On leaving home Wi-Fi, normal unmount is requested. ForceUnmount and
  LazyUnmount are disabled: a busy filesystem can remain mounted until users
  close its files and another stop succeeds. Existing CIFS mounts may still try
  to reconnect; no new NAS probes or mount requests are initiated by the helper
  outside home Wi-Fi. Stop explicitly after closing files if needed:
  `sudo systemctl stop vault-{home,Downloads,music,video,Store}.mount` (Bash).
- Auth remains `/etc/samba/vault.credentials`, outside Git, with the existing
  username/password and optional domain. `cifs-utils` remains installed, and
  `boot.supportedFilesystems = [ "cifs" ]` explicitly preserves the mount helper
  integration previously inferred from `fileSystems`.
- During the first switch, the old `/vault` mount/automount must be stopped
  before using the new child mounts. A ConditionPathIsMountPoint guard refuses
  child mounts while `/vault` itself is still mounted, avoiding creation of
  mountpoint directories inside the old remote share. Close applications using
  the old share; no forced unmount or remote data migration is performed.
- Tests: `python3 -B -m unittest discover -s tests -p test_home_smb_network.py -v`.

Swap:

- `modules/nixos/swap.nix` declares `/swapfile` through `swapDevices`.
- Size is `16 * 1024` MiB, exactly 16 GiB.
- The root filesystem is ext4, so no Btrfs-specific swapfile handling is
  needed. NixOS creates and initializes a missing file through its generated
  `mkswap-*.service`, then activates the corresponding systemd swap unit.
- Hibernate/resume uses the systemd-based initrd and systemd 260's
  `HibernateLocation` UEFI variable. Immediately before hibernation systemd
  records the ext4 swapfile's backing device and current physical offset; the
  initrd resume generator reads them on the next boot. Do not add a static
  `resume_offset`: it would become invalid if `/swapfile` were recreated.
- The machine has about 15.3 GiB RAM, while swap is 16 GiB and the kernel's
  current hibernation image limit is about 6.1 GiB. `CanHibernate` and
  `CanSuspendThenHibernate` both report `yes`.
- `systemd.sleep.settings.Sleep` explicitly enables suspend, hibernate and
  suspend-then-hibernate, uses `mem` + `deep` for suspend, `disk` + `platform`
  for hibernate, and sets `HibernateDelaySec=2h` plus
  `HibernateOnACPower=true`.
- `boot.kernelParams` contains `mem_sleep_default=deep`. The ThinkPad firmware
  advertises ACPI S3 and S4, and `/sys/power/mem_sleep` exposes both `s2idle`
  and `deep`, so this is supported rather than a forced unavailable state.

Закрытие крышки запускает suspend-then-hibernate при питании от батареи, сети
и в docked-режиме:

```nix
services.logind.settings.Login = {
  HandleLidSwitch = "suspend-then-hibernate";
  HandleLidSwitchExternalPower = "suspend-then-hibernate";
  HandleLidSwitchDocked = "suspend-then-hibernate";
};
```

In Hyprland, logind is the lid owner. Plasma 6.6 PowerDevil always takes a
low-level `handle-lid-switch` inhibitor, which systemd intentionally cannot
override. Therefore `configure-plasma-sleep-policy` converges only the relevant
regular writable `powerdevilrc` keys for AC/Battery/LowBattery: `LidAction=1`
(Sleep), `SleepMode=3` (SuspendThenHibernate), external-monitor inhibition off,
and `AutoSuspendAction=0`. Thus Plasma remains the sole lid owner in its own
session but requests the same systemd operation, including while docked, and it
does not add an idle suspend timer. The helper runs at Home Manager activation
and before Plasma startup; do not replace `powerdevilrc` with a read-only store
symlink.

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

`modules/nixos/throne.nix` enables Throne through the upstream NixOS module.
`programs.throne.tunMode.enable = true` installs the `throne-core` capability
wrapper and the narrow polkit integration needed for Throne to configure
per-link DNS through `systemd-resolved` without repeated password prompts.
The package is system-wide; its real Hyprland window class is `Throne` and has
a dedicated Waybar workspace icon.

IPv6 is disabled intentionally for now. The Wi-Fi network advertises IPv6 routes
and DNS returns AAAA records, but real IPv6 TCP connections stay in `SYN-SENT`
and time out. GUI applications such as Firefox, Telegram, Discord, and Happ can
then appear broken even while IPv4 `curl` and `ping` work. Keep IPv6 disabled
until the upstream network or VPN path has working IPv6; then this can be
revisited.
IPv6 traffic is blocked at two configuration layers while IPv6 support remains
loaded in the kernel. `networking.enableIPv6 = false` applies the global/default
sysctl policy, and a oneshot service sets `ipv6.method=disabled` on every
non-loopback NetworkManager profile. The latter is necessary because profiles
with `ipv6.method=auto` otherwise keep trying to create link-local addresses and
can fill the journal with retries. The matching dispatcher applies the same
setting to newly created Wi-Fi, Ethernet and VPN profiles and updates their
active device immediately. Both scripts identify profiles by UUID and change
only `ipv6.method`; Wi-Fi secrets remain in NetworkManager storage and are never
copied into Nix or logs.

Do not add the kernel parameter `ipv6.disable=1` while Happ uses sing-box TUN
mode. It removes the kernel AF_INET6 routing API and `/proc/sys/net/ipv6`
entirely. Sing-box with `auto_route`/`strict_route` still initializes IPv6 route
handling for an IPv4-only TUN; without that kernel API it creates `tun0` and
then exits with code 1. Keeping the IPv6 kernel control plane available does not
enable IPv6 traffic: the NixOS sysctls and NetworkManager profiles above remain
disabled.

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
FHS wrapper does not stat or bind the `/vault` tree while enumerating
host directories. This prevents unavailable shares below `/vault` from delaying Steam's
`bubblewrap` startup; all other host directories retain the standard Nixpkgs
Steam behavior. `dotglob` is disabled again after assigning `GLOBIGNORE` to
avoid changing which hidden root entries the wrapper enumerates.
Для встроенной Intel Iris Xe (Alder Lake-P) включен современный VA-API driver
`intel-media-driver` (`iHD_drv_video.so`) и oneVPL/QSV runtime `vpl-gpu-rt` через
`hardware.graphics.extraPackages`. `LIBVA_DRIVER_NAME=iHD` явно выбирает этот
driver вместо устаревшего `i965`. Это необходимо для hardware video decoding в
Moonlight; без `iHD` клиент сообщает, что не обнаружил functioning hardware
accelerated video decoder. `libva-utils` установлен для проверки командой
`vainfo` после system switch и нового входа в графическую сессию.
`android-tools` установлен системно и предоставляет `adb`/`fastboot`. Отдельный
`programs.adb` и группа `adbusers` в NixOS 26.05 не нужны: systemd 258+ выдает
доступ к подключенному Android-устройству через `uaccess` активному локальному
пользователю.
В `environment.systemPackages` находятся Kitty, Dolphin, Kate, Thunar,
`nwg-look`, `qt5ct`, `qt6ct`, Papirus, Bibata, pavucontrol, blueman,
brightness/audio helpers, hardware/network diagnostics including `efibootmgr`
и `os-prober`, compiler/dev tools. Codex берется из отдельного
`nixpkgs-codex` input, закрепленного на `nixpkgs/master`, потому что
`nixos-unstable` может отставать от самого свежего релиза Codex.
Bitwarden Desktop остается на отдельном `nixpkgs-unstable` input.
Так security-sensitive приложения обновляются точечно без перевода
всей системы на unstable/master. Home Manager получает
`pkgsUnstable` через `home-manager.extraSpecialArgs`.
Текущий pin `nixpkgs-codex` от `2026-09-11` предоставляет Codex CLI
`0.154.0`; pin `nixpkgs-unstable` от `2026-09-05` — Bitwarden Desktop
`2026.8.0`. Bitwarden использует поддерживаемый Electron `43.4.1`;
глобального исключения `permittedInsecurePackages` для старого Electron нет.
После обновления input нужно проверить запуск Codex, разблокировку vault,
browser integration и Bitwarden SSH agent; при функциональной регрессии
откатывать весь system generation, а не возвращать EOL Electron в allowlist.

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

- desktop session isolation between Hyprland and Plasma
- Firefox Hyprland wrapper
- Codex permission profile and writable user configuration
- Fish
- Hyprland
- Kitty
- Mako
- Neovim
- ручных пакетов `manual.nix`
- removable media through udiskie, available through `~/media`
- Rofi
- network menus
- package installer
- Starship
- VS Code и декларативных extensions/settings
- Waybar
- Wlogout

`home/ilya/codex.nix` declaratively generates a writable
`~/.codex/config.toml`. Codex uses the custom `workspace-full` permission
profile with `approval_policy = "never"`: the active workspace root, its `.git`
metadata, `/tmp`, and `$TMPDIR` are writable; the rest of the filesystem is
read-only. `.git` needs an explicit rule because Codex protects repository
metadata even under an otherwise writable workspace; `.codex` remains
read-only. Network access is enabled for all domains.
Only the user D-Bus and Bitwarden SSH-agent Unix sockets are allowlisted; broad
Unix-socket access is intentionally not enabled because services such as the
Nix daemon or Docker could bypass the filesystem boundary. Because the active
workspace comes from the launch directory, starting Codex in `$HOME` makes the
whole home directory writable; normally launch it in the repository that should
be editable. Disallowed operations fail immediately instead of displaying an
approval prompt.

The same module configures the `nix` MCP server using the pinned
`pkgs.mcp-nixos` package rather than `uvx` or an unpinned `nix run`. It exposes
live search and reference data for Nixpkgs packages, NixOS and Home Manager
options, flakes, Nixvim, nix.dev and related Nix resources. MCP tools are
approved automatically; the server remains query-only and does not replace
local flake evaluation or authorize rebuild/activation commands.

Home Manager задает только общие для обеих desktop-сессий session variables:

- `EDITOR = "nvim"`
- `TERMINAL = "kitty"`
- `SSH_AUTH_SOCK = "/home/ilya/.bitwarden-ssh-agent.sock"`

Hyprland-specific variables live in `hyprland.nix` as `envd`, so they reach
applications, D-Bus activation and Hyprland user services but are removed from
the user service manager when that session stops:

- `BROWSER = "/home/ilya/.local/bin/firefox-hyprland"`
- cursor theme/size из единого `home/ilya/appearance.nix`
- GTK dark preference and Catppuccin theme
- Qt platform theme `kde`
- Qt Quick Controls style `org.kde.desktop`
- `XDG_CURRENT_DESKTOP = "Hyprland"`
- `XDG_MENU_PREFIX = "plasma-"`; this makes KDE's `KService`/`KSycoca` use
  `/etc/xdg/menus/plasma-applications.menu` outside a full Plasma session, so
  Dolphin and the KDE portal AppChooser can discover installed applications
- `XDG_SESSION_DESKTOP = "Hyprland"`

Plasma receives none of these overrides. Its native SDDM/startplasma session
sets the KDE environment and uses normal Plasma defaults.

Параметры оформления Hyprland собраны в `home/ilya/appearance.nix`: scale,
cursor theme/package/size, icon theme/package, UI и monospace fonts, GTK theme
и Qt/KDE theme names. Hyprland modules import this file, so a change updates
Hyprcursor/XCursor, GTK, dconf and the temporary Hyprland `kdeglobals`. Cursor
size is `30`, matching the enlarged Hyprland scale. Rofi, Mako, qt5ct/qt6ct и
Hyprland `kdeglobals` также получают имена и шрифты из `appearance.nix`.
Plasma does not consume `appearance.nix` and owns its appearance settings.

Тема Hyprland задана без Stylix и без тяжелого theming framework.
Базовая палитра: Catppuccin Macchiato Blue. Это нежно-темно-синяя схема:
темная база `#24273a`, основной текст `#cad3f5`, синий акцент `#8aadf4`,
фиолетовый вторичный акцент `#c6a0f6`.

- GTK: `catppuccin-macchiato-blue-standard`, пакет `catppuccin-gtk`
  с `variant = "macchiato"`, `accents = [ "blue" ]`, `size = "standard"`.
- During Hyprland, dconf uses
  `org/gnome/desktop/interface color-scheme = prefer-dark` and the same GTK
  theme name. The previous dconf state is restored at Hyprland logout.
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
- While Hyprland is active, `~/.config/kdeglobals` embeds the full Catppuccin
  `[Colors:*]` sections, not
  only `ColorScheme=CatppuccinMacchiatoBlue`. KDE apps outside Plasma do not
  reliably expand the scheme name by themselves. Home Manager generates the
  declarative source as `~/.config/.home-manager-kdeglobals`; the session
  profile copies it to a regular writable `~/.config/kdeglobals` with mode
  `0600` at Hyprland login and restores Plasma's file at logout. Do not manage
  `kdeglobals` as a direct `xdg.configFile` symlink: KDE's `KConfig` resolves
  that symlink into `/nix/store`, fails to create `hm_kdeglobals.lock`, and Qt
  applications such as Telegram can abort when opening a file chooser.
- GTK3/GTK4 settings and GTK4 Catppuccin CSS/assets are copied into their
  active paths only for the duration of a Hyprland session. Plasma gets its
  own GTK settings and native theme synchronizer.
- KDED's `gtkconfig` module is disabled in the temporary Hyprland
  `~/.config/kded5rc`. Letting
  `gtkconfig` rewrite GTK CSS, dconf and xsettingsd configuration at runtime
  caused Waybar, udiskie, NetworkManager/Bluetooth applets and the GTK portal
  to segfault together while their GLib file monitors handled those writes.
  Plasma's `device_automounter` KDED module is disabled in the same temporary
  file so it cannot race udiskie. Both modules are available normally in
  Plasma, where udiskie is not started.
- Kitty, Rofi, Mako, Waybar, Wlogout, Starship, Hyprland borders and
  Hyprlock use the same Macchiato palette directly in their own modules.

Hyprland default applications are managed declaratively in
`home/ilya/home.nix` through the desktop-specific
`~/.config/hyprland-mimeapps.list`. Plasma has no Home Manager MIME override
and uses its normal defaults or settings chosen through System Settings. This
keeps a runtime generic `~/.config/mimeapps.list` from coupling the sessions.
The desktop-specific file contains only `[Default Applications]`: according to
GIO, `[Added Associations]` belongs in the generic `mimeapps.list` and is
ignored in a desktop-specific file.

Current default app policy:

- web links and HTML: `firefox.desktop`, whose Exec uses the shared-profile
  wrapper in both desktops.
- images: `org.kde.gwenview.desktop`.
- video/audio: `vlc.desktop`.
- PDFs and document-like files: Okular desktop entries.
- archives: `org.kde.ark.desktop`.
- directories: `org.kde.dolphin.desktop`.
- plain text: `org.kde.kate.desktop`.
- code/config formats: `code.desktop`.

`firefox.desktop` intentionally does not advertise image MIME types. The
`firefox-hyprland` command remains the Hyprland keybinding/BROWSER entry point,
but it is only a thin wrapper around the same launcher used by that canonical
desktop entry.

### Hyprland / Plasma Session Isolation

`home/ilya/desktop-session-isolation.nix` keeps desktop behavior separate while
ordinary application data remains shared under the same Unix user and HOME.

- `desktop-session-profile` runs as a oneshot service before
  `hyprland-session.target`. It saves Plasma's active `kdeglobals`, `kded5rc`,
  GTK3/GTK4 settings and GNOME interface dconf values, installs exact
  declarative Hyprland versions plus the Firefox button-hiding `userChrome.css`,
  then restores the saved Plasma state and removes that Firefox CSS when the
  target stops.
- The implementation is `home/ilya/desktop-session-profile.sh`, included by
  the Nix module through `builtins.readFile` and wrapped with its runtime tools.
  It copies a complete Plasma snapshot into `session-v2.pending` before changing
  any live file, then commits it by rename to `session-v2`. Phases are `saving`
  (pending only), `saved`, `applying`, `active`, `restoring`, and `restored`.
  Phase updates use rename and filesystem sync before destructive operations.
- Restore copies from the snapshot; it never consumes saved originals. A
  process interrupted during apply or restore can therefore run again. A
  Hyprland start completes an interrupted restore before taking a new snapshot.
  Missing snapshot entries or unknown phases cause a failure before live files
  are changed. Concurrent desktop sessions under the same user remain unsupported.
- Completed snapshots are retained under
  `~/.local/state/nixos-desktop-isolation/backups/completed.*/snapshot`.
  They are not automatically pruned. They contain desktop settings and dconf,
  not browser profiles or other application data. Manually review old snapshots
  before removing them if this directory grows significantly.
- Existing `active-hyprland` v1 state is copied verbatim into the migration
  snapshot and archived as `backups/legacy-v1.*/snapshot` only after v2 is
  committed. Saved entries take precedence; entries already restored by v1
  are recovered from HOME. Explicit `.absent` markers stay absent. If an active
  legacy snapshot lacks dconf data, migration refuses to guess. Data already
  deleted by an earlier v1 retry cannot be reconstructed automatically.
- Exact declarative Hyprland settings are reapplied at every Hyprland start.
  KDE/GTK changes made interactively inside Hyprland must still be moved into
  Home Manager to persist. Firefox userChrome is absent in Plasma as before;
  any current CSS discarded during capture is retained in the snapshot.
- GTK4 assets copied from the store become owner-writable. Removing a live
  symlink does not chmod its target. A failed operation may temporarily leave
  mixed live settings, but the committed originals remain available for retry.
- A Plasma pre-start script at
  `~/.config/plasma-workspace/env/00-desktop-session-profile.sh` performs the
  same restore before Plasma reads its workspace configuration.
- The one-time initial Plasma reset still respects `plasma-reset-v1`. For a
  fresh setup it first copies all affected originals and dconf to
  `initial-reset-v2.pending`, commits `initial-reset-v2`, then resets settings.
  That snapshot is retained and the marker records its location. Existing
  installations with the marker do not repeat the reset.
- Recovery tests: `python3 -B -m unittest discover -s tests -v`. They execute
  the real shell script with temporary HOME/runtime directories and mocked
  dconf/systemctl/sync, killing the process at mutation boundaries. They cover
  both recovery destinations, legacy partial save/restore, initial reset,
  missing snapshots/sources, symlinks, absent files and nested directories.
  This checks process interruption, not physical power-loss durability.
- Before rolling back to a generation with the old v1 implementation, log out
  normally so v2 restores Plasma first; the old script cannot interpret v2 state.
- `nm-applet`, `blueman-applet` and `udiskie` are wanted by and part of
  `hyprland-session.target`, never the generic graphical target. User-level
  overrides for the package-provided `nm-applet.desktop` and `blueman.desktop`
  contain `NotShowIn=KDE` plus `X-systemd-skip=true`, preventing Plasma
  autostart duplicates while the supervised Hyprland services remain the only
  applet processes.
- `awww-daemon` is also a supervised member of
  `hyprland-session.target`; Hyprland only sends the unchanged wallpaper
  command after startup. This gives the daemon `SIGTERM` during the existing
  session-target shutdown instead of leaving it to abort when its Wayland
  connection disappears.
- Shared application data and config such as Steam, Proton, Telegram,
  Bitwarden, Discord, Obsidian, browsers, games, Git, Fish and Neovim are not
  moved into alternate XDG roots and remain common to both sessions.
- Do not replace this with separate global `XDG_CONFIG_HOME` or
  `XDG_DATA_HOME` values: that would unnecessarily split ordinary application
  profiles, contrary to the intended design.
- Plasma's package-provided `drkonqi-coredump-launcher@.service` has a Home
  Manager `ExecCondition` drop-in. The graphical crash reporter starts only
  while a real Wayland or local X11 socket exists. This preserves normal
  DrKonqi behavior in a live Plasma session but prevents a compositor-shutdown
  crash from making DrKonqi abort without a display and recursively report its
  own aborts.

## Пользовательские Пакеты

Базовые Home Manager пакеты лежат в `home/ilya/home.nix`.

Туда входят Hyprland stack, CLI tools, Bitwarden Desktop, Telegram,
Moonlight Qt, `networkmanagerapplet`, Catppuccin GTK/KDE themes, `direnv`, `nix-direnv`,
`lazygit`, `delta`, `gh`, `net-tools` (включая `ifconfig`) и прочее.

Moonlight установлен как `pkgs.moonlight-qt` из закрепленного stable
Nixpkgs. Это PC client для Sunshine/NVIDIA GameStream; отдельные
udev/uinput rules на client side не добавлены. Waybar mapping учитывает
upstream desktop ID `com.moonlight_stream.Moonlight` и Qt class-варианты
`moonlight`/`Moonlight`; после первого запуска реальный class нужно
сверить через `hyprctl clients`.

Ручные пакеты, добавленные командой `nix-install`, лежат отдельно:

```text
home/ilya/packages/manual.nix
```

Актуальный список намеренно не дублируется в документации: источником истины
служит сам `home/ilya/packages/manual.nix`. Это позволяет helper-у добавлять
пакеты без превращения `NOTES.md` в рассинхронизированный второй package list.

MPV установлен декларативно как `pkgs.mpv` в списке ручных пользовательских
пакетов. MIME-ассоциации при этом не меняются: VLC остается видеоплеером по
умолчанию.

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

Для 32-битных Windows-игр вроде Colin McRae: DiRT 2 установлены
`wineWow64Packages.stagingFull`, `winetricks`, `cabextract` и `vulkan-tools`.
32-битные Mesa/Vulkan drivers и PipeWire ALSA support включены системно.
Steam package добавляет FAudio через `extraLibraries`; поскольку Steam FHS
multiarch, библиотека попадает и в обычный Steam runtime, и в `steam-run` для
`x86_64` и `i686`. Самораспаковывающиеся сборки с собственными Wine/DXVK нужно
запускать как `steam-run ./имя-файла.run`: это даёт их нениксовым ELF-файлам
FHS layout, 32-битный Vulkan loader, Intel Mesa driver, звук и FAudio.
Системный Wine 11 staging остаётся запасным вариантом для замены старого
bundled Wine; сама игра и её файлы конфигурацией не устанавливаются.

После смены hostname с `nixos` на `thinkpad-nix` пришлось один раз удалить
`~/.cache/spotify/SingletonCookie`, `SingletonLock` и `SingletonSocket`: они
остались с lock target `nixos-51010`, из-за чего новые запуски из
Rofi молча завершались с кодом 1. Это runtime cleanup, а не постоянная часть
конфигурации.

`happ` не приходит из nixpkgs и установлен локальным derivation
`home/ilya/packages/happ.nix` из official GitHub release
`Happ-proxy/happ-desktop` версии `3.3.6`. Пакет использует upstream asset
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
The daemon remains a root service because TUN mode, routing changes and
cross-user process inspection are part of its upstream protocol. Do not add
`NoNewPrivileges`, a capability bounding set, `DevicePolicy=closed` or strict
filesystem/address-family sandboxing to this unit: upstream explicitly states
that `happd` must launch unrestricted privileged sing-box/Xray children. The
previous filesystem sandbox also prevented Happ from writing
`/var/log/happd.log`, which hid the useful daemon diagnostics. Independently,
the `ipv6.disable=1` kernel parameter made `sing-box-tun` exit with code 1 just
after creating `tun0`; the networking section documents why the kernel IPv6
control plane must remain present even though IPv6 traffic stays disabled.
`Restart=always` matches upstream because a newly upgraded GUI may ask an older
daemon to exit successfully before systemd starts the matching binary.
`/var/lib/happd` remains the daemon's private state directory. The upstream hard-coded
`/tmp/happd.sock` path remains shared with the desktop client, but an
`ExecStartPost` guard changes it to `root:users 0660` after every daemon start;
the desktop session therefore does not need a logout before it can reconnect.
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
Текущий seed `2026-08-14` повторно загружен и проверен 2026-08-20: обе
загрузки побайтово совпали, ZIP/JAR прошли проверку целостности, а подпись JAR
валидна для `TLauncher Inc.` через Certum Code Signing 2021 CA.

`bitwarden-desktop` установлен по явному решению пользователя и берется из
закрепленного `nixpkgs-unstable`: stable оставался на Bitwarden `2026.5.0` с
EOL Electron 39, тогда как unstable предоставляет Bitwarden `2026.7.0` с
поддерживаемым Electron 41. Не возвращать `electron-39.8.10` в
`permittedInsecurePackages`; если будущий Bitwarden снова потребует insecure
runtime, сначала искать обновление или откатывать generation.

Bitwarden Desktop не имеет декларативного автозапуска: нет XDG autostart
entry, user systemd service или Hyprland `exec-once`. Он запускается только
вручную. Сам пакет, vault data, polkit policy и SSH-agent integration при этом
остаются установленными. Не включать `Start automatically on login` в UI,
иначе Bitwarden снова создаст runtime-autostart вне Home Manager.

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

- Waybar starts through its Home Manager systemd user service, not Hyprland
  `exec-once`; the service records failures and restarts the bar after a crash.
- `mako`
- `awww-daemon`
- `sleep 0.5 && awww img ...` sets the wallpaper from
  `assets/wallpapers/wallhaven-2eqpzm.png`
- `hypridle` starts through the Home Manager user service, bound to
  `hyprland-session.target`, with automatic restart after 10 seconds.
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
  "HDMI-A-1,1920x1200@59.95,0x0,1.25,mirror,eDP-1"
  ",preferred,auto,1.25"
];
```

The current Wayland UI scale is `1.25`, restoring the established size for
native Wayland applications and desktop components. Avoid also adding global
`QT_SCALE_FACTOR`, `GDK_SCALE`, or manual font bumps, because that can
double-scale parts of the UI. KDE may still have its own scaling behavior
because it is preserved as a separate fallback session.

The laptop panel is `eDP-1` and the physical HDMI connector is `HDMI-A-1`.
Hyprland applies the explicit HDMI monitor rule automatically on hotplug and
mirrors `eDP-1` onto it. The explicit `1920x1200@59.95` mode is supported by the
tested EPSON projector and matches the laptop panel's 1920x1200 aspect ratio;
do not use `preferred` here because that projector incorrectly advertises
1024x768 as preferred, which also forces Hyprland away from the requested 1.25
scale. The generic fallback rule remains in place for all other outputs, so the
built-in panel and non-HDMI outputs retain their previous preferred-mode,
automatic-position and `1.25` scale behavior.

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
Print             select an area and copy it directly to the clipboard
Shift+Print       copy the entire output to the clipboard
Ctrl+Print        select an area and open it in Swappy
Ctrl+Shift+Print  capture the entire output and open it in Swappy
SUPER+F           fullscreen
SUPER+Space       floating toggle
SUPER+P           pseudo
SUPER+O           layoutmsg togglesplit
```

All four screenshot bindings use `home/ilya/hypr/screenshot.sh`, packaged with
explicit runtime dependencies by `writeShellApplication`. A shared nonblocking
`flock` in `XDG_RUNTIME_DIR` ignores repeated requests while selecting, capturing,
or editing in Swappy. Cancellation leaves the clipboard unchanged; `grim` must
succeed before the image is passed on. Temporary PNG files are removed on exit.
Clipboard/editor children do not inherit the lock descriptor.

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

- without HDMI, `hypridle` locks after 300 seconds and turns displays off after
  600 seconds;
- while the physical `HDMI-A-1` connector reports `connected`, both idle screen
  actions are skipped by the Nix-generated `allow-hypridle-screen-action`
  helper. This keeps presentations visible without changing global timers or
  adding polling. A missing connector status fails safe and allows normal idle
  locking;
- every fullscreen Hyprland window gets `idle_inhibit fullscreen`, so games
  controlled only by a gamepad do not trigger either timer; leaving fullscreen
  restores normal idle handling without polling or a helper process;
- manual/session D-Bus lock requests remain unconditional, and before sleep:
  `loginctl lock-session`; HDMI therefore suppresses only automatic idle lock
  and idle DPMS, never the security lock used for suspend/hibernate;
- after sleep: `hyprctl dispatch dpms on`;
- `services.hypridle` generates the config and user service; there is no
  duplicate `exec-once` launch or user `sleep.target` hook. Hypridle handles
  logind sleep notifications directly. `inhibit_sleep = 2` selects lock
  notification waiting automatically for this hyprlock configuration, bounded
  by logind’s inhibitor delay limit;
- after migrating from `exec-once`, log out and back into Hyprland after
  applying the configuration so the old unmanaged process is replaced.
- neither Hyprland nor Plasma automatically suspends on idle;
- lid close and the Wlogout sleep action request
  `systemctl suspend-then-hibernate`: resume is immediate when woken normally,
  otherwise systemd wakes by RTC and hibernates no later than two hours later
  (or earlier on a firmware low-battery alarm).

## Firefox

System Firefox is enabled through NixOS.

Hyprland does not launch plain `firefox` from `SUPER+B`; it launches:

```text
/home/ilya/.local/bin/firefox-hyprland
```

Источник: `home/ilya/firefox/firefox.nix`.

`~/.mozilla/firefox/hyprland` is the single canonical Firefox profile for both
desktops. It contains the pre-existing Hyprland history, cookies, logins,
extensions, preferences and session; the old `5fyajafy.default` directory is
left untouched as a fallback and is not merged into the canonical profile.

`firefox-shared` always launches the absolute Nix store Firefox binary with
`--profile ~/.mozilla/firefox/hyprland`. `~/.local/bin/firefox` and
`firefox-hyprland` are thin entry points to that shared launcher;
`~/.local/bin` is explicitly first in the session `PATH`. `firefox.desktop`
uses the bare command `firefox`, while `BROWSER` and `SUPER+B` use
`firefox-hyprland`. A Home Manager activation helper registers `hyprland` as
the default profile in `profiles.ini` and current `installs.ini` sections,
backing up the metadata before its first change. This also makes otherwise
plain Firefox launches select the shared profile.

Both desktops use the canonical `firefox.desktop` ID for HTTP/HTTPS, HTML and
XHTML. Do not restore a separate `firefox-hyprland.desktop`. Firefox's Linux
default-browser implementation compares the executable in GIO's handler
command with `MOZ_APP_LAUNCHER`; the NixOS Firefox wrapper sets the latter to
the relative name `firefox`. Therefore both the desktop entry and the first
`PATH` match must remain `firefox`. Pointing the desktop entry directly at
`firefox-shared` makes the comparison permanently fail even if every MIME
default is correct. The activation helper normalizes only Firefox-related
entries in the generic `mimeapps.list`, preserves unrelated associations, and
moves old generated `userapp-Firefox-*.desktop` files into the isolation backup
directory.

The existing `toolkit.legacyUserProfileCustomizations.stylesheets` and
tabs-in-titlebar preferences live in a declarative `user.js`. The session
profile installs the exact previous button-hiding `chrome/userChrome.css` only
while Hyprland is active and removes it before Plasma starts. Thus all browser
data and settings are shared, while Hyprland has no titlebar buttons and Plasma
uses the normal Firefox buttons. Firefox must be restarted after switching
desktops because userChrome is loaded at profile startup.

HTTP/HTTPS links, HTML files, `BROWSER` and `SUPER+B` all use the same wrapper.
Firefox remoting is left enabled, so a new URL is handed to an already running
Hyprland-profile instance instead of starting another browser instance. When
the wrapper receives a URL and finds an existing Firefox window through
`hyprctl -j clients`, it then runs `focuswindow class:^(firefox)$`; Hyprland
therefore switches to workspace 2 and focuses Firefox after opening the link.

Firefox remoting remains enabled and is now safe across both launchers because
they always name the same profile. The same profile must not be opened by two
simultaneous Firefox instances; normal sequential Plasma/Hyprland sessions are
supported.

## Telegram

Telegram установлен как `pkgsTelegram.telegram-desktop` из отдельного
`nixpkgs-telegram` input (`nixos-unstable`). Версия 7.2.8 заменяет 6.8.1 из
основного stable input. Этот input передаётся только в Home Manager; обновление
Telegram не требует обновлять Bitwarden, Codex или всю систему. Для следующего
обновления используется `nix flake update nixpkgs-telegram`, затем evaluation
и dry-run. Остальные lock entries должны оставаться прежними.

Для него нет
локального wrapper-а, дополнительных environment variables, подмены desktop
entry или DBus service, MIME association и Hyprland window rules. Приложение
запускается с полностью upstream-конфигурацией пакета.

Пользовательские данные Telegram в `~/.local/share/TelegramDesktop`, кэш и
прочие runtime-файлы декларативной конфигурацией не управляются и не удаляются.

## Waybar

Файл: `home/ilya/waybar/waybar.nix`.

Waybar uses `programs.waybar.systemd.enable = true`. Its user service is tied
directly to `hyprland-session.target`, logs failures in the user journal and
has `Restart=on-failure`; do not add a second direct `waybar` launch to
Hyprland `exec-once`.

The Hyprland config runs `systemctl --user stop hyprland-session.target` from
`exec-shutdown` and waits 100 ms before the compositor exits. The target adds
`PropagatesStopTo=graphical-session.target`, matching the upstream Hyprland
session lifecycle recommendation. Consequently Waybar, tray applets and other
graphical-session services receive a normal systemd stop while the Wayland
display is still alive. This prevents the previous failure mode where Waybar
lost the display, `Restart=on-failure` rapidly retried six times with
`cannot open display`, hit `start-limit-hit`, and stayed down in the next
Hyprland session. Keep the restart policy: it still recovers a real Waybar
crash while the current compositor session is healthy.

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

- `output = [ "!HDMI-A-1" "*" ]` excludes only the mirrored HDMI output.
  The bar on `eDP-1` is already part of the mirrored image, so starting another
  Waybar instance on `HDMI-A-1` causes redundant hotplug reconfiguration. Other
  non-HDMI outputs remain eligible through the trailing `*` fallback.
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
- Existing mappings cover the installed desktop applications, including the
  live-verified `Bitwarden` and `org.qbittorrent.qBittorrent` classes, plus
  Discord, VLC, Prism Launcher, Ark, Thunar, Blueman, appearance tools and
  Swappy. Regexes include expected Wayland app IDs and XWayland class variants
  where an application can expose either.
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
user service `nm-applet.service` with `Restart=on-failure`, wanted only by
`hyprland-session.target`, поэтому сетевой индикатор должен жить в Hyprland
tray постоянно и никогда не запускаться в Plasma. `blueman-applet` устроен так
же: `blueman-applet.service` принадлежит только Hyprland target, а Plasma
использует свой BlueDevil indicator.

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
- Suspend → Hibernate (`systemctl suspend-then-hibernate`)
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

Точка входа: `home/ilya/nvim/nvim.nix`; Lua-конфигурация разложена по
`home/ilya/nvim/lua/config/` и `home/ilya/nvim/lua/plugins/`.

Базовый слой редактора:

- используется полноценный LazyVim, а не самостоятельный набор несвязанных
  plugin setup;
- LazyVim, все плагины и внешние инструменты берутся из Nix store. Mason и
  фоновые проверки/загрузки lazy.nvim отключены;
- Trouble остаётся основным списком diagnostics/tests, но его необязательные
  document-symbol breadcrumbs в Lualine отключены: текущие версии LazyVim и
  Trouble имеют startup race при регистрации режима `symbols`;
- тема `catppuccin-<variant>` автоматически берёт variant из общего
  `home/ilya/appearance.nix`, сейчас это Catppuccin Macchiato;
- line numbers
- relative numbers
- spaces, 2-space indent
- smart indent
- true color
- sign column
- system clipboard
- leader: space
- `nvim-cmp` + LSP/signature/path/buffer completion и LuaSnip;
- Treesitter parsers для C, C++, CMake, Python, LaTeX, BibTeX и основных
  config/markup-языков. Parser binaries объединены с plugin runtime явно,
  поскольку LazyVim не использует Home Manager wrapper для plugins.

C/C++ и Python IDE:

- `clangd` работает с background index, clang-tidy, detailed completion,
  include insertion, inlay hints и `compile_commands.json`; `clang-format`,
  CMake, Ninja, Bear и `codelldb` установлены через Nix;
- CMake Tools предоставляет configure/preset/build type/target/build/run/debug
  и создаёт/линкует `compile_commands.json`;
- одиночные C17/C++20 файлы собираются с `-Wall -Wextra -Wpedantic -g -O0`,
  но эти флаги никогда не накладываются на CMake/Make проекты;
- Python использует BasedPyright для типов/navigation/completion и Ruff для
  lint/code actions/imports/format. Ruff hover отключён, чтобы не дублировать
  BasedPyright;
- `.venv`, `venv`, активное окружение и выбор через Venv Selector согласованы
  с запуском, pytest, LSP и debugpy; выбор Venv Selector сохраняется по проекту;
- Neotest настроен для pytest и CTest; CTest adapter понимает GoogleTest,
  Catch2 и другие поддерживаемые CTest frameworks, но не навязывает framework;
- DAP использует `codelldb` и `debugpy`; DAP UI открывается только на старте
  debug session и закрывается при её завершении;
- format-on-save ограничен C/C++ (`clang-format`) и Python (`ruff format`).
  TeX/BibTeX намеренно не передаются Conform.

Project runner mappings: `<leader>rr` run current, `<leader>rR` repeat,
`<leader>ra` run with args, `<leader>rs` stop, `<leader>rp` arbitrary project
command, `<leader>rm` Python module, visual `<leader>rx` Python selection,
`<leader>cb` build and `<leader>df` debug current. CMake mappings use
`<leader>m`: `mc/mb/mr/md/mt/mp/my` for configure/build/run/debug/target/preset/
build type. Standard LazyVim LSP, DAP, Neotest and format mappings are retained.
Дополнены только отсутствовавшие DAP actions: `<leader>dL` log point и
`<leader>dR` restart текущей session.

LaTeX-окружение:

- `texliveFull` предоставляет TeX Live, `latexmk`, Biber, SyncTeX и обычные
  учебные/математические пакеты;
- VimTeX является единственным владельцем непрерывной сборки через `latexmk`;
- TexLab отвечает за completion, diagnostics, definitions/references и не
  запускает собственную сборку (`build.onSave = false`);
- LTeX+ и встроенный spellcheck проверяют русский и английский текст;
- Zathura используется для PDF, автоматически перечитывает PDF и поддерживает
  forward/inverse SyncTeX через уже запущенный Neovim;
- `neovim-remote` доступен для внешней интеграции;
- `%! TEX root = ../main.tex` поддерживается VimTeX и LSP root detection;
- TeX-файлы получают word-boundary wrap и conceal математических символов;
  стрелки вверх/вниз в normal, visual и insert mode двигаются по экранным, а
  не физическим строкам;
- BibTeX использует Treesitter highlighting. LaTeX parser установлен, но
  VimTeX syntax оставлен активным, поскольку от него зависят conceal и text
  objects.

Стандартные VimTeX mappings не дублируются: `\ll` compile, `\lk` stop,
`\lv` view/forward search, `\le` errors, `\lo` output, `\li` project info,
`\lc` clean и `\lC` full clean.

Zathura как новое GUI-приложение имеет отдельное class-to-icon правило Waybar.

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
systemctl --user restart waybar.service
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
9. Screenshot bindings use `grim`, `slurp`, `wl-copy` and `swappy`: plain
   `Print` and `Shift+Print` copy an area or the entire output directly to the
   clipboard; adding `Ctrl` opens the captured image in Swappy instead.
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
