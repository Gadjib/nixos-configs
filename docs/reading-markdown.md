# Чтение Markdown в терминале

## Назначение

Этот документ объясняет, как читать и редактировать локальные `.md`-файлы из `docs/` без интернета. Основные найденные инструменты в системе - `glow`, `bat`, `less`, `nvim` и `yazi`. `glow` добавлен через `home/ilya/packages/manual.nix`.

## glow

`glow` удобен для полноценного Markdown-рендера в терминале: заголовки, списки, таблицы и ссылки выглядят ближе к финальному виду.

```bash
glow docs/index.md
glow docs
```

В режиме просмотра обычно работают стрелки, `j/k`, `PageUp/PageDown`, `/` для поиска, `q` для выхода. `glow docs` открывает браузер Markdown-файлов по директории. Преимущество над `bat`: Markdown именно рендерится, а не просто подсвечивается как текст.

Если после rollback или смены generation команды нет:

```bash
command -v glow
```

См. рекомендации по reader/editor пакетам в [SUGGESTED_PACKAGES.md](SUGGESTED_PACKAGES.md).

## bat

`bat` - быстрый просмотр с подсветкой синтаксиса, номерами строк и pager.

```bash
bat docs/index.md
bat -n docs/index.md
bat --paging=always docs/emergency.md
bat --plain docs/index.md
```

Когда пользоваться: быстро проверить файл, скопировать строку, посмотреть diff-like фрагмент. В твоем fish `cat` алиасится на `bat`.

## less

`less` есть почти всегда и полезен в emergency/TTY.

```bash
less docs/emergency.md
```

Клавиши:

| Клавиша | Действие |
|---|---|
| `/текст` | поиск вперед |
| `n` | следующий результат |
| `N` | предыдущий результат |
| `q` | выйти |
| `g` | начало файла |
| `G` | конец файла |
| `Space` | страница вниз |
| `b` | страница вверх |

## nvim

```bash
nvim docs/index.md
nvim docs/nixos/rebuild.md
```

Базовая навигация: `/текст`, `n`, `N`, `:e path/to/file.md`, `:w`, `:q`, `:wq`. Для редактирования нажмите `i`, внесите изменения, `Esc`, затем `:w`.

Если Neovim не запускается, emergency fallback:

```bash
vim docs/emergency.md
nano docs/emergency.md
```

## yazi

```bash
yazi docs
```

Выберите файл стрелками или `j/k`, откройте `Enter`. Preview pane обычно показывает текст/Markdown как plain text или с подсветкой, если доступны preview-зависимости. Если preview пустой, откройте файл через `bat` или `nvim`.

## GUI-варианты

- VSCodium/VSCode: удобно для поиска по всему репозиторию и Markdown preview.
- Obsidian: удобен как offline knowledge base, если установлен.
- KDE Kate: системный GUI-редактор; пакет `kdePackages.kate` есть в system packages.

## Поиск по всей документации

```bash
rg "rollback" docs
rg -n "journalctl|systemctl" docs
fd -e md . docs
fd nixos docs
fd -e md . docs | fzf
bat "$(fd -e md . docs | fzf)"
```

## HTML/PDF через pandoc

Если установлен `pandoc`:

```bash
pandoc docs/index.md -o /tmp/index.html
pandoc docs/index.md -o /tmp/index.pdf
```

Для большой книги лучше сначала собрать список файлов вручную, чтобы порядок был правильным:

```bash
pandoc docs/index.md docs/system-overview.md docs/emergency.md -o /tmp/nixos-manual.html
```

## Частые ошибки

- `glow: command not found`: пакет не установлен.
- Русский текст выглядит странно: проверьте locale и шрифт терминала; kitty настроен на `JetBrainsMono Nerd Font`.
- `less` показывает escape-последовательности: используйте `less -R`.
- Markdown-ссылки не кликаются в терминале: это нормально; открывайте целевой файл вручную.

## Troubleshooting

```bash
command -v bat less nvim yazi
locale
echo $PAGER
```

Если нужно читать в TTY, используйте `less` или `vim`: они требуют меньше графической инфраструктуры.

## Cheatsheet

```bash
bat docs/index.md
bat -n docs/emergency.md
less docs/emergency.md
nvim docs/index.md
yazi docs
rg "текст" docs
fd -e md . docs | fzf
```
