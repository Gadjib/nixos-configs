# Offline manual для NixOS/Hyprland/CLI

Эта документация описывает локальную систему из репозитория `/home/ilya/nixos-config`: NixOS 26.05 с flakes, Home Manager для пользователя `ilya`, Hyprland как основную Wayland-сессию, KDE Plasma 6 как fallback, fish/kitty/waybar/rofi/mako/yazi и современный CLI-стек. Она рассчитана на работу без интернета: в самолете, в TTY, после неудачного rebuild или при настройке окружения.

## Как пользоваться offline

Открывайте главную страницу и переходите по разделам:

```bash
cd /home/ilya/nixos-config
bat docs/index.md
less docs/index.md
nvim docs/index.md
```

`glow` сейчас установлен через `home/ilya/packages/manual.nix`, поэтому удобно читать так:

```bash
glow docs
glow docs/nixos/rebuild.md
```

Если после отката generation `glow` пропал, используйте `bat`, `less` или `nvim`. Подробнее про чтение Markdown: [reading-markdown.md](reading-markdown.md), а про дополнительные reader/editor пакеты - [SUGGESTED_PACKAGES.md](SUGGESTED_PACKAGES.md).

## Что читать сначала

- Новый обзор системы: [system-overview.md](system-overview.md).
- Изоляция Hyprland и Plasma описана в разделе «Независимость Hyprland и
  Plasma» файла [system-overview.md](system-overview.md).
- Ежедневная работа: [daily-workflow.md](daily-workflow.md).
- Срочный ремонт: [emergency.md](emergency.md).
- Rebuild и rollback: [nixos/rebuild.md](nixos/rebuild.md), [nixos/rollback.md](nixos/rollback.md).
- Hyprland hotkeys: [hyprland/keybindings.md](hyprland/keybindings.md).
- CLI-карта: [cli/index.md](cli/index.md).
- Короткие шпаргалки: [cheatsheets/index.md](cheatsheets/index.md).

## Поиск по документации

```bash
rg "rebuild" docs
rg -n "Hyprland|waybar|mako" docs
fd yazi docs
fd -e md . docs | fzf
nvim "$(fd -e md . docs | fzf)"
```

Искать команды лучше через `rg`:

```bash
rg "nixos-rebuild|nh os|home-manager" docs
rg "journalctl|systemctl|nmcli" docs
```

## Где лежит конфиг

- Репозиторий: `/home/ilya/nixos-config`.
- Flake: `flake.nix`.
- Хост: `hosts/nixos/configuration.nix`.
- Системные модули: `modules/nixos/`.
- Home Manager: `home/ilya/home.nix`.
- Ручные пользовательские пакеты через helper `nix-install`: `home/ilya/packages/manual.nix`.
- Hyprland: `home/ilya/hypr/hyprland.nix`.
- Kitty/Rofi/Mako/Waybar/fish: `home/ilya/*/*.nix`.

Системная конфигурация отвечает за boot loader, SDDM, KDE, Hyprland как системную программу, PipeWire, Bluetooth, NetworkManager, шрифты и системные пакеты. Home Manager отвечает за пользовательские программы, shell, Hyprland-настройки, waybar, rofi, mako, kitty, темы и пользовательские XDG-файлы. Актуальный список пакетов, добавленных через `nix-install`, находится непосредственно в `home/ilya/packages/manual.nix`.

## После изменения конфига

Перед rebuild:

```bash
git status
git diff
```

Безопасный порядок:

```bash
nh os test /home/ilya/nixos-config
git add -A
git commit -m "Describe the configuration change"
nh os switch /home/ilya/nixos-config
```

В fish есть алиасы:

```fish
rebuild-test
rebuild-switch
```

Не запускайте `switch`, если `test` не собирается. Не запускайте `nixos-rebuild` из случайной директории без понимания, какой flake применяется.

## Опасные команды

Проверяйте дважды:

```bash
sudo nix-collect-garbage -d
sudo rm -rf ...
rsync --delete ...
git reset --hard
git clean -fdx
sudo systemctl disable ...
```

`nix-collect-garbage -d` удаляет старые поколения профилей и может забрать возможность быстро откатиться на них из текущей системы. Boot menu обычно все еще показывает поколения, пока они не удалены и пока entries есть в `/boot`.

## Как откатиться

- Самый надежный способ: выбрать предыдущую generation в GRUB при старте.
- Из рабочей системы: `sudo nixos-rebuild switch --rollback` или `nh os rollback`.
- Для Home Manager: `home-manager switch --rollback`.
- Для git-конфига: `git diff`, затем точечно вернуть файл через `git restore path`, если вы уверены.

Подробно: [nixos/rollback.md](nixos/rollback.md) и [emergency.md](emergency.md).

## Типовые ситуации

- Hyprland не стартует: [emergency.md](emergency.md), [hyprland/troubleshooting.md](hyprland/troubleshooting.md).
- Нет сети: [cli/network.md](cli/network.md), [cheatsheets/network-cheatsheet.md](cheatsheets/network-cheatsheet.md).
- Не хватает места: [nixos/garbage-collection.md](nixos/garbage-collection.md), [cli/system-monitoring.md](cli/system-monitoring.md).
- Нужно быстро вспомнить git: [cli/git-lazygit-delta-gh.md](cli/git-lazygit-delta-gh.md).
- Нужно разобрать файлы: [cli/yazi.md](cli/yazi.md).

## Как обновлять эту документацию

После изменения системы обновляйте соответствующий `.md`: поменяли Hyprland keybinding - обновите `docs/hyprland/keybindings.md`; добавили пакет - обновите `docs/system-overview.md`, `docs/cli/index.md` или профильный manual.

Перед коммитом:

```bash
git diff
rg TODO docs
rg VERIFY docs
```

Коммитьте документацию вместе с config, чтобы offline manual не расходился с реальной системой. Если Codex менял систему, отдельно просите его обновить `docs/`.

## Cheatsheet

```bash
cd /home/ilya/nixos-config
rg "текст" docs
bat docs/index.md
less docs/emergency.md
nvim docs/nixos/rebuild.md
nh os test /home/ilya/nixos-config
git add -A
git commit -m "Describe the configuration change"
nh os switch /home/ilya/nixos-config
```
