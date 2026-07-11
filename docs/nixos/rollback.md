# Rollback

## Назначение

Rollback возвращает систему, Home Manager или git-конфиг в предыдущее рабочее состояние.

## Boot menu

Самый надежный вариант: при загрузке выбрать предыдущую generation в GRUB. Используйте, если новая система не грузится, SDDM не стартует, Hyprland/KDE не дают войти.

После входа исправьте репозиторий:

```bash
cd /home/ilya/nixos-config
git status
git diff
```

## Rollback NixOS из системы

```bash
sudo nixos-rebuild switch --rollback
nh os rollback
```

`nh os rollback` есть в локальном `nh os --help`.

## Rollback git-конфига

Сначала посмотреть:

```bash
git diff
git status
```

Вернуть конкретный файл:

```bash
git restore home/ilya/hypr/hyprland.nix
```

Не используйте `git reset --hard`, если есть несохраненные изменения, которые могут быть нужны.

## Rollback Home Manager

```bash
home-manager generations
home-manager switch --rollback
```

Такой rollback полезен, если сломался пользовательский shell, Hyprland user config, kitty, rofi, waybar.

## Как не потерять рабочий config

- Делайте маленькие commits.
- Перед risk change: `git diff`.
- После успешного `switch`: проверьте login, terminal, network, audio, screenshots.
- Не чистите старые generations сразу.

## Частые ошибки

- Откатили running system, но оставили плохой git diff; следующий rebuild снова сломает систему.
- Удалили старые generations через GC.
- Вернули весь repo вместо одного файла.

## Troubleshooting

```bash
nh os info
home-manager generations
journalctl -b -p err
git log --oneline --decorate -20
git show --stat HEAD
```

## Cheatsheet

```bash
# boot menu: выбрать старую generation
sudo nixos-rebuild switch --rollback
nh os rollback
home-manager switch --rollback
git diff
git restore path/to/file
```
