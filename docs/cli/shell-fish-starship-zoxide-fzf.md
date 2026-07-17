# Fish, Starship, Zoxide, FZF

## Назначение

Fish - интерактивный shell; Starship - prompt; Zoxide - умный `cd`; FZF - интерактивный выбор.

## Fish

Конфиг: `/home/ilya/nixos-config/home/ilya/fish/fish.nix`, runtime `~/.config/fish/config.fish`.

Включено:

```fish
starship init fish | source
zoxide init fish | source
direnv hook fish | source
fzf --fish | source
```

Базовые команды:

```fish
set var value
echo $var
history
functions
abbr
alias
fish_config
```

Проверить синтаксис:

```bash
fish -n ~/.config/fish/config.fish
fish --no-config
```

Временно перейти в bash:

```bash
bash
/run/current-system/sw/bin/bash
```

## Алиасы

```fish
ls
ll
la
cat
grep
lg
rebuild-test
rebuild-switch
```

## Функция nix-install

В `home/ilya/fish/fish.nix` определена отдельная package-функция:

```fish
nix-install glow
```

Она вызывает `/home/ilya/.local/bin/nix-install-package glow`. Helper требует
чистый Git worktree, проверяет пакет в текущем flake, добавляет его в
`home/ilya/packages/manual.nix`, делает dry-run build, создает commit и затем
запускает `nh os switch /home/ilya/nixos-config`.

Обычный `/run/current-system/sw/bin/install` из coreutils не переопределяется:

```fish
install -m 755 source target
```

Package helper сам проверяет рабочее дерево, но его состояние можно заранее
посмотреть вручную:

```bash
cd /home/ilya/nixos-config
git status
```

## Starship

Starship показывает статус prompt: директория, git, языки, exit code. Конфиг управляется `home/ilya/starship/starship.nix` и runtime `~/.config/starship.toml`.

Troubleshooting fonts:

```bash
fc-match "JetBrainsMono Nerd Font"
starship explain
```

## Zoxide

```fish
z nixos
z Downloads
zi
z -
```

Zoxide учится по директориям, куда вы реально переходите.

## FZF

```bash
fd -e nix | fzf
rg -n "pattern" | fzf
nvim "$(fd -e md docs | fzf)"
```

Fish integration обычно дает keybindings вроде history/file search. VERIFY: точные `Ctrl+R`/`Ctrl+T` проверьте через `bind | rg fzf` внутри fish.

## Troubleshooting

```bash
command -v fish starship zoxide fzf direnv
fish --no-config
fish -n ~/.config/fish/config.fish
bind | rg fzf
```

## Cheatsheet

```fish
z project
zi
fd . | fzf
rg "text" | fzf
fish --no-config
bash
```
