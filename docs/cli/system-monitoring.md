# System monitoring

## Назначение

Диагностика процессов, ресурсов, места на диске, логов и systemd-сервисов.

## btop

```bash
btop
```

Показывает CPU, RAM, disks, network, процессы. Используйте поиск/filter внутри интерфейса; для kill процесса выбирайте процесс и action kill. VERIFY: точные клавиши смотрите в help btop (`?`).

## dust

```bash
dust .
dust -d 2 /nix
dust /nix/store
```

Находит, что занимает место.

## duf

```bash
duf
duf / /boot /home
```

Показывает filesystems, mountpoints, usage.

## procs

```bash
procs
procs waybar
procs hypr
```

Удобная замена `ps`.

## journalctl

```bash
journalctl -b
journalctl -b -p err
journalctl -b -u NetworkManager
journalctl --user -b
journalctl --user -b -u waybar
journalctl -f
```

## systemctl

System services:

```bash
systemctl status NetworkManager
sudo systemctl restart NetworkManager
systemctl --failed
```

User services:

```bash
systemctl --user status xdg-desktop-portal
systemctl --user restart xdg-desktop-portal
```

На NixOS enable/disable лучше делать декларативно в config, а не вручную.

## Cheatsheet

```bash
btop
dust .
duf
procs name
systemctl --failed
journalctl -b -p err
journalctl --user -b
```
