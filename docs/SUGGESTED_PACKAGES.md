# Suggested packages

Это список пакетов для чтения и поддержки Markdown-документации. Часть может уже быть добавлена в текущую конфигурацию.

## glow

- Статус: уже установлен через `home/ilya/packages/manual.nix`.
- Зачем: красивый Markdown reader в терминале, умеет открывать файл и директорию.
- Куда: `home.packages` или `home/ilya/packages/manual.nix`, потому что нужен пользователю.
- Использование:

```bash
glow docs
glow docs/index.md
```

- Обязательность: высокая полезность; уже доступен. `bat`/`less` остаются fallback.

## mdcat

- Зачем: простой renderer Markdown в терминале, удобен для pipe/quick view.
- Куда: `home.packages`.
- Использование:

```bash
mdcat docs/index.md
```

- Обязательность: optional.

## pandoc

- Зачем: собрать HTML/PDF/один большой документ из Markdown.
- Куда: `home.packages` или temporary `nix shell`, если редко нужен.
- Использование:

```bash
pandoc docs/index.md -o /tmp/index.html
pandoc docs/index.md -o /tmp/index.pdf
```

- Обязательность: optional, полезен для экспорта.

## marksman

- Зачем: Markdown language server для ссылок, outline, completion в editor.
- Куда: `home.packages`, если Neovim/VSCode будет использовать LSP.
- Использование: подключается редактором как LSP.
- Обязательность: optional.

## markdownlint-cli

- Зачем: проверка стиля Markdown.
- Куда: `home.packages` или devShell для repo docs.
- Использование:

```bash
markdownlint docs
```

- Обязательность: optional. VERIFY: имя пакета в nixpkgs может быть `markdownlint-cli` или вариант с Node package; проверить через `nix search nixpkgs markdownlint`.

## vale

- Зачем: prose linter, можно проверять русский/английский стиль, термины и опечатки.
- Куда: devShell или `home.packages`.
- Использование:

```bash
vale docs
```

- Обязательность: optional; нужен только если хочется строгий writing workflow.

## Obsidian

- Зачем: GUI knowledge base для Markdown, удобная навигация по `docs/`.
- Куда: `home.packages`, если нужен GUI reader/editor.
- Использование: открыть vault на `/home/ilya/nixos-config/docs`.
- Обязательность: optional GUI.

## VSCode/VSCodium

- Зачем: GUI editor, поиск по repo, Markdown preview, extensions.
- Куда: `home.packages` или system package по предпочтению.
- Использование:

```bash
codium /home/ilya/nixos-config
code /home/ilya/nixos-config
```

- Обязательность: optional GUI. VSCodium предпочтительнее, если нужен open-source build.

## Минимальный набор

Если на другой машине добавлять только одно: `glow`.

Если нужен экспорт: `pandoc`.

Если нужен редакторский комфорт: `marksman` + `markdownlint-cli`.
