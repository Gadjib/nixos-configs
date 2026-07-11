# NixOS cheatsheet

## Rebuild

```bash
cd /home/ilya/nixos-config
git diff
nh os test /home/ilya/nixos-config
nh os switch /home/ilya/nixos-config
sudo nixos-rebuild test --flake .#nixos
sudo nixos-rebuild switch --flake .#nixos
```

## Rollback

```bash
# boot menu: выбрать старую generation
sudo nixos-rebuild switch --rollback
nh os rollback
home-manager switch --rollback
git restore path
```

## GC

```bash
duf
dust /nix/store
nh os info
sudo nix-collect-garbage --delete-older-than 14d
sudo nix-collect-garbage -d
```

## Packages

```bash
nix shell nixpkgs#pkg
nix run nixpkgs#pkg
nix search nixpkgs pkg
nvim home/ilya/home.nix
nvim modules/nixos/packages.nix
```

## Home Manager

```bash
home-manager generations
home-manager packages
home-manager switch --rollback
```

## Flakes

```bash
nix flake show
nix flake update
git diff flake.lock
nix flake check
```
