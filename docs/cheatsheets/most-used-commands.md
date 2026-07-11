# Most used commands

| Задача | Команда |
|---|---|
| Перейти в config | `cd /home/ilya/nixos-config` |
| Умный переход | `z nixos` |
| Список файлов | `ll` |
| Дерево | `eza --tree -L 2` |
| Найти файл | `fd pattern` |
| Найти текст | `rg "text" .` |
| Просмотр | `bat file` |
| Редактор | `nvim file` |
| File manager | `yazi .` |
| Git status | `git status` |
| Git diff | `git diff` |
| Git TUI | `lg` |
| NixOS test | `nh os test /home/ilya/nixos-config` |
| NixOS switch | `nh os switch /home/ilya/nixos-config` |
| Logs errors | `journalctl -b -p err` |
| Failed services | `systemctl --failed` |
| Disks | `duf` |
| Disk usage | `dust .` |
| Processes | `btop` |
| Network | `nmcli device status` |

## Проверка перед commit

```bash
git diff
rg TODO docs
rg VERIFY docs
```
