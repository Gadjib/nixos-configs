# Файлы и поиск: eza, bat, fd, rg

## Назначение

Эти утилиты покрывают 80% работы с файлами: посмотреть, найти имя, найти текст, открыть фрагмент.

## eza

```bash
eza
eza -lah --icons --group-directories-first
eza --tree -L 2
eza --git
eza --sort=modified
```

В fish `ls`, `ll`, `la` уже алиасятся на `eza`.

## bat

```bash
bat file
bat -n file
bat --paging=always file
bat --plain file
bat -r 20:80 file
```

Используйте для Nix, Markdown, logs, JSON/YAML.

## fd

```bash
fd name
fd -e nix
fd -H hidden
fd -I ignored
fd -e md . docs
fd pattern -x bat {}
```

## rg

```bash
rg "text"
rg -n "text" path
rg -i "case"
rg "pattern" -g "*.nix"
rg -C 3 "pattern"
rg --hidden "pattern"
rg "old" -r "new"
```

По NixOS config:

```bash
rg "environment.systemPackages|home.packages" .
rg "SUPER|bind" home/ilya/hypr
rg "NetworkManager|pipewire|plasma6" modules hosts
```

## Частые ошибки

- Не нашли hidden file: добавьте `-H`.
- Не нашли ignored file: добавьте `-I`.
- Regex интерпретирует спецсимволы: используйте `rg -F "literal.text"`.

## Troubleshooting

```bash
command -v eza bat fd rg
fd --help
rg --help
```

## Cheatsheet

```bash
ll
eza --tree -L 2
bat -n file
fd -e nix
rg -n "text" .
rg -F "literal" .
```
