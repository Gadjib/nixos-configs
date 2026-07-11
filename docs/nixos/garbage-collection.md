# Garbage collection

## Назначение

`/nix/store` растет, потому что Nix хранит старые пакеты и поколения для rollback. Garbage collection удаляет больше не достижимые store paths.

## Когда пользоваться

- Мало места на `/`.
- Большой `/nix/store`.
- Много старых generations.
- После стабильной работы новой системы несколько дней.

## Проверить место

```bash
df -h
duf
dust /nix/store
df -h /boot
nh os info
home-manager generations
```

## Безопасная чистка

Удалить старше 14 дней:

```bash
sudo nix-collect-garbage --delete-older-than 14d
```

Home Manager:

```bash
home-manager expire-generations "-14 days"
```

## Агрессивная чистка

```bash
sudo nix-collect-garbage -d
```

Она удаляет старые поколения профилей. Не делайте это сразу после рискованного изменения, иначе rollback станет сложнее.

## nh clean

Если используете `nh`:

```bash
nh clean --help
nh clean all --keep 3 --keep-since 14d
```

VERIFY: точные flags `nh clean` проверьте через `nh clean --help`, потому что интерфейс может отличаться между версиями.

## Boot generations limit

В `hosts/nixos/configuration.nix` задано:

```nix
boot.loader.grub.configurationLimit = 10;
```

Это ограничивает количество NixOS boot entries в GRUB.

## Частые ошибки

- Чистить aggressively до проверки новой generation.
- Путать место в `/boot` и `/nix/store`.
- Удалять вручную из `/nix/store`.

## Troubleshooting

```bash
df -h / /boot
duf
dust -d 2 /nix
sudo nix-store --gc --print-dead
sudo nix-collect-garbage --delete-older-than 7d
```

## Cheatsheet

```bash
duf
dust /nix/store
nh os info
sudo nix-collect-garbage --delete-older-than 14d
sudo nix-collect-garbage -d
home-manager expire-generations "-14 days"
```
