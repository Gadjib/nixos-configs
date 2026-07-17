# Ежедневный workflow

## Назначение

Практический сценарий обычного дня: открыть терминал, перейти в проект, найти файлы, редактировать, посмотреть git, сделать rebuild и обновить docs.

## Старт

В Hyprland терминал открывается `SUPER+Enter` и запускает `kitty`. Shell - `fish`, prompt - `starship`.

```fish
pwd
ls
ll
```

Алиасы из Home Manager:

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

Также есть Fish-функция `nix-install`: `nix-install <pkgname>` требует чистый
Git worktree, добавляет пакет в `home/ilya/packages/manual.nix`, выполняет
dry-run, создает отдельный commit и только затем запускает `nh os switch`.
Стандартная coreutils-команда `install` не переопределяется.

## Переход в проект

`zoxide` учится по посещенным директориям:

```fish
z nixos
z config
zi
cd /home/ilya/nixos-config
```

Если `z` не знает путь, один раз перейдите обычным `cd`.

## Поиск файлов и текста

```bash
fd hypr
fd -e nix
fd -e md . docs
rg "waybar"
rg -n "rebuild-switch|nh os" .
rg "SUPER" home/ilya/hypr
```

Интерактивно:

```bash
nvim "$(fd -e nix | fzf)"
bat "$(fd -e md docs | fzf)"
```

## Просмотр и редактирование

```bash
bat home/ilya/hypr/hyprland.nix
nvim home/ilya/hypr/hyprland.nix
yazi .
```

Yazi удобен для навигации, preview и файловых операций; подробный manual: [cli/yazi.md](cli/yazi.md).

## Git

Перед изменениями:

```bash
git status
git diff
```

После изменений:

```bash
git diff
git add docs
git commit -m "docs: add offline system manual"
```

Для интерактивной работы:

```bash
lg
lazygit
```

## Rebuild

Порядок для NixOS-конфига:

```bash
cd /home/ilya/nixos-config
git diff
rebuild-test
git add -A
git commit -m "Describe the configuration change"
rebuild-switch
```

`test` активирует конфиг до reboot и не делает его boot default. `switch` делает новое поколение активным и boot default.

## Откат

Если после `test` что-то сломалось, перезагрузитесь или выполните rollback. Если после `switch` система грузится плохо, выберите старую generation в GRUB.

```bash
sudo nixos-rebuild switch --rollback
home-manager switch --rollback
nh os rollback
```

## Обновление документации

После изменения конфигурации:

```bash
rg TODO docs
rg VERIFY docs
git diff docs
```

Обновляйте manual рядом с изменениями: keybinding - в Hyprland docs, пакет - в CLI/System overview, rebuild-логика - в NixOS docs.

## Частые ошибки

- Открыли файл из `/etc` и правите generated config: правьте репозиторий, не `/etc`.
- Запустили `switch` без `git diff`: сложно понять, что именно сломалось.
- Забыли docs: через месяц manual уже не соответствует системе.

## Cheatsheet

```bash
SUPER+Enter
z nixos
fd -e nix | fzf
rg "текст" .
bat file
nvim file
lg
rebuild-test
rebuild-switch
```
