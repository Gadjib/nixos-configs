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

## Функция install

В `home/ilya/fish/fish.nix` определена функция `install`. Если первый аргумент не похож на option, команда:

```fish
install glow
```

вызывает `/home/ilya/.local/bin/nix-install-package glow`. Helper проверяет пакет в текущем flake, добавляет его в `home/ilya/packages/manual.nix`, делает dry-run build и затем запускает `nh os switch /home/ilya/nixos-config`.

Это не то же самое, что обычный `/run/current-system/sw/bin/install` из coreutils. Для option-like вызовов функция передает управление настоящей команде:

```fish
install -m 755 source target
```

Перед использованием package helper проверяйте рабочее дерево:

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
