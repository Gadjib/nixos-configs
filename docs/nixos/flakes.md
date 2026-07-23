# Flakes

## Назначение

Flake фиксирует inputs и outputs проекта. В этой системе flake задает NixOS-конфигурацию `nixos` и подключает Home Manager.

## Файлы

- `flake.nix` - описание inputs/outputs.
- `flake.lock` - зафиксированные ревизии inputs.

`flake.nix` использует `nixpkgs` ветки `nixos-26.05` и Home Manager `release-26.05`.

## Inputs

Inputs - внешние источники:

```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
home-manager.url = "github:nix-community/home-manager/release-26.05";
home-manager.inputs.nixpkgs.follows = "nixpkgs";
```

`follows` заставляет Home Manager использовать тот же nixpkgs, что и система.

## Outputs

Главный output:

```nix
nixosConfigurations.nixos = nixpkgs.lib.nixosSystem { ... };
```

Hostname в конфиге - `thinkpad-nix`, но имя flake-output остается `nixos`,
поэтому команды по-прежнему используют `#nixos`.

## Обновление inputs

```bash
cd /home/ilya/nixos-config
nix flake update
git diff flake.lock
nh os test /home/ilya/nixos-config
```

Если обновление ломает сборку, откатите `flake.lock`:

```bash
git restore flake.lock
```

## Rebuild через flake

```bash
sudo nixos-rebuild test --flake /home/ilya/nixos-config#nixos
sudo nixos-rebuild switch --flake /home/ilya/nixos-config#nixos
```

`nh os test /home/ilya/nixos-config` сам понимает flake.

## Типичные ошибки lockfile

- `flake.lock` изменился после `nix flake update`, но не проверен rebuild.
- `nixpkgs` и Home Manager на разных релизах.
- Переименовали `nixosConfigurations.nixos`, но команды все еще используют `#nixos`.
- Работаете в dirty tree и не понимаете, какие файлы влияют на сборку.

## Troubleshooting

```bash
nix flake show /home/ilya/nixos-config
nix flake metadata /home/ilya/nixos-config
nix flake check /home/ilya/nixos-config
git diff flake.nix flake.lock
```

## Cheatsheet

```bash
nix flake show
nix flake update
git diff flake.lock
sudo nixos-rebuild test --flake .#nixos
nh os test /home/ilya/nixos-config
```
