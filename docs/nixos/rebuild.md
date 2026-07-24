# NixOS rebuild

## Назначение

Rebuild собирает и применяет декларативную конфигурацию. В этой системе предпочтительный инструмент - `nh`, а низкоуровневая команда - `nixos-rebuild`.

## Перед rebuild

```bash
cd /home/ilya/nixos-config
git status
git diff
```

`git diff` нужен, чтобы понимать, какие изменения попадут в generation. Перед
`switch` актуальное состояние нужно закоммитить, чтобы у каждой примененной
generation была понятная Git-точка отката.

## nixos-rebuild

```bash
sudo nixos-rebuild test --flake /home/ilya/nixos-config#thinkpad-nix
sudo nixos-rebuild switch --flake /home/ilya/nixos-config#thinkpad-nix
sudo nixos-rebuild boot --flake /home/ilya/nixos-config#thinkpad-nix
```

- `test`: собрать и активировать до reboot, не делать boot default.
- `switch`: собрать, активировать и сделать boot default.
- `boot`: собрать и сделать boot default, но не активировать сейчас.

## nh

`nh os --help` показывает команды `switch`, `boot`, `test`, `build`, `info`, `rollback`, `clean`.

```bash
nh os test /home/ilya/nixos-config
nh os switch /home/ilya/nixos-config
nh os boot /home/ilya/nixos-config
nh os info
```

В fish настроены алиасы:

```fish
rebuild-test
rebuild-switch
```

## Как читать ошибки сборки

Ищите:

- `error:` - главное сообщение;
- `while evaluating the option` - какая option сломалась;
- `The option ... does not exist` - неверное имя option или версия nixpkgs;
- `attribute ... missing` - пакет/атрибут не найден;
- путь к файлу и строке: `path/to/file.nix:line:column`.

Команды:

```bash
nh os test /home/ilya/nixos-config
sudo nixos-rebuild test --flake /home/ilya/nixos-config#thinkpad-nix --show-trace
```

Копировать ошибку удобно через mouse selection в kitty: выделение копируется в clipboard из-за `copy_on_select = clipboard`.

## Типичные сценарии

Добавили пакет:

```bash
nvim home/ilya/home.nix
git diff
rebuild-test
git add home/ilya/home.nix NOTES.md
git commit -m "Add package"
rebuild-switch
```

Изменили Hyprland keybinding:

```bash
nvim home/ilya/hypr/hyprland.nix
rebuild-test
hyprctl reload
```

Обновили flake inputs:

```bash
nix flake update
git diff flake.lock
nh os test /home/ilya/nixos-config
```

## Частые ошибки

- Запустить rebuild не из того flake.
- Применить `switch` без проверки `test`.
- Применить `switch` до commit проверенного состояния.
- Не заметить, что Home Manager встроен в NixOS rebuild, и запускать отдельный `home-manager switch` без необходимости.
- Оставить незакоммиченный рабочий config без документации.

## Troubleshooting

```bash
git diff
rg "сломанная_option|packageName" .
nix flake show /home/ilya/nixos-config
nix flake check /home/ilya/nixos-config
nh os test /home/ilya/nixos-config -v
```

## Cheatsheet

```bash
git diff
nh os test /home/ilya/nixos-config
git add -A
git commit -m "Describe the configuration change"
nh os switch /home/ilya/nixos-config
sudo nixos-rebuild test --flake /home/ilya/nixos-config#thinkpad-nix
sudo nixos-rebuild switch --rollback
```
