# CLI stack

## Назначение

Карта терминальных утилит, установленных через Home Manager и system packages.

## Замены привычных команд

| Классика | Современная команда | Когда использовать |
|---|---|---|
| `ls` | `eza` | списки файлов, дерево, git info |
| `cat` | `bat` | просмотр файлов с подсветкой |
| `find` | `fd` | быстрый поиск файлов |
| `grep` | `rg` | быстрый поиск текста |
| `cd` | `zoxide` | переход по часто используемым директориям |
| `top` | `btop` | мониторинг CPU/RAM/processes |
| `du` | `dust` | что занимает место |
| `df` | `duf` | диски и mountpoints |
| `ps` | `procs` | процессы |
| file manager | `yazi` | TUI файловый менеджер |
| git gui | `lazygit` | интерактивный git |
| curl api | `httpie` | удобные HTTP-запросы |

Отдельно: в Fish есть helper `nix-install <pkgname>`, который на чистом Git
worktree добавляет пакет в `home/ilya/packages/manual.nix`, проверяет dry-run,
создает commit и запускает `nh os switch`. Это не замена `nix shell` для
временных экспериментов.

## Топ-20 команд на каждый день

```bash
ll
z nixos
fd -e nix
rg "text" .
bat file
nvim file
yazi .
git status
git diff
lg
nh os test /home/ilya/nixos-config
duf
dust .
btop
journalctl -b -p err
systemctl --failed
nmcli device status
ip addr
wl-paste
cliphist list
```

## Когда что использовать

- Нужно найти файл: `fd name`.
- Нужно найти текст: `rg "pattern"`.
- Нужно понять размер: `dust`.
- Нужно проверить диск: `duf`.
- Нужно открыть дерево файлов: `yazi`.
- Нужно сделать commit: `git` или `lazygit`.
- Нужно проверить сервис: `systemctl status name`.
- Нужно читать логи: `journalctl`.

## Частые ошибки

- Использовать `rm` вместо `trash-put` для неуверенного удаления.
- Искать через медленный `find`, когда хватает `fd`.
- Делать `grep -R` по repo вместо `rg`.
- Запускать глобальные пакетные менеджеры вместо per-project env.

## Cheatsheet

```bash
fd pattern
rg "pattern"
bat file
yazi .
lg
btop
duf
dust .
```
