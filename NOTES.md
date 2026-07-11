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
│   ├── nix.nix
│   ├── packages.nix
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
- Waybar
- Wlogout

Home Manager также задает session variables:

- `EDITOR = "nvim"`
- `TERMINAL = "kitty"`
- `BROWSER = "firefox"`
- cursor theme/size
- GTK dark preference
- Qt platform theme `qt6ct`
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
- Qt 5/6: `QT_QPA_PLATFORMTHEME=qt6ct`, `QT_STYLE_OVERRIDE=kvantum`.
  Generated `qt5ct.conf` / `qt6ct.conf` use `style=kvantum` with local
  `catppuccin-macchiato.conf` color schemes.
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
`vlc`, `vscode`.

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

Keyboard:

- layouts: `us,ru`
- switch: `Alt+Shift`

Touchpad:

- natural scroll
- tap-to-click
- tap-and-drag
- drag lock
- clickfinger behavior
- middle button emulation
- scroll factor `0.9`

Gestures:

- 3 fingers horizontal: workspace switching
- 4 fingers horizontal: workspace switching
- 4 fingers down: special workspace `magic`
- 4 fingers up: fullscreen
- 3 fingers pinch out: fullscreen
- 3 fingers pinch in: float
- 4 fingers pinch out: cursor zoom x2
- 4 fingers pinch in: cursor zoom reset

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
- `drun-use-desktop-cache = true`.
- Goal: `SUPER+D` should prefer frequently/recently launched apps near the top
  while keeping the implementation inside native Rofi config.

Rofi theme uses visible transparency for the launcher background:
`bg = #24273acc`, `surface = #363a4fd9`.

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
