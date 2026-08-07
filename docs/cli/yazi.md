# Yazi manual

## Назначение

Yazi - быстрый TUI-файловый менеджер для терминала. Он полезен, когда нужно просматривать директории, видеть preview, выбирать несколько файлов, копировать/перемещать/удалять, открывать файлы в редакторе или внешних приложениях.

В этой системе пакет `yazi` установлен через `home.packages`. Пользовательский конфиг `~/.config/yazi` не найден, поэтому ниже описаны preset keybindings из локального `man yazi` для установленного Yazi `26.5.6`. Если позже появится `~/.config/yazi/keymap.toml`, он может переопределить эти клавиши.

## Запуск

```bash
yazi
yazi .
yazi ~/Downloads
```

`yazi --help` подтверждает запуск с `[ENTRIES]...`, а также опции `--cwd-file`, `--chooser-file`, `--clear-cache`, `--debug`.

## Интерфейс

Обычно Yazi показывает:

- left/parent panel - родительская директория;
- center/current panel - текущая директория;
- right/preview pane - preview файла или директории;
- status line - путь, режим, выбранные файлы, подсказки;
- selection markers - выбранные элементы;
- hidden files - показываются отдельной командой/keybinding.

## Навигация

| Действие | Клавиши |
|---|---|
| Вверх/вниз | `k`/`j`, стрелки |
| Войти в директорию | `l`, стрелка вправо |
| Открыть выбранное | `o`, `Enter` |
| Назад к parent | `h`, `Backspace` |
| Вверх/вниз на 5 строк | `K`/`L` |
| Home/end списка | `g g` / `G` |
| Jumps в home/root/config/downloads | проверь в `keymap.toml` |
| Поиск вперед/назад в текущей папке | `/` / `?` |
| Следующий/предыдущий результат | `n` / `N` |
| Фильтр | `f` |
| Hidden files | `.` |
| Jump через zoxide | `z` |
| Jump/reveal через fzf | `Z` |

Проверить реальные бинды после добавления конфига:

```bash
bat ~/.config/yazi/keymap.toml
rg "home|root|Downloads|filter|search" ~/.config/yazi
```

## Открытие файлов

| Действие | Команда |
|---|---|
| Open | `o`/`Enter` |
| Open interactively | `O`/`Ctrl+Enter` |
| Reveal | зависит от opener; проверь config |
| Editor | обычно через `$EDITOR`, в системе `EDITOR=nvim` |
| Terminal here | VERIFY, часто через shell command |

Preview limitations: изображения/PDF/архивы требуют preview backend и терминальной поддержки. Если preview пустой, используйте `bat`, `file`, `7z l`, `pdftotext` если установлен.

## Выбор файлов

| Действие | Клавиши |
|---|---|
| Select one | `Space` |
| Select multiple | `Space` по нескольким файлам |
| Select all | `Ctrl+a` |
| Invert selection | `Ctrl+r` |
| Visual mode selection | `v` |
| Visual mode unset | `V` |
| Снять selection | `Esc` |

## Операции с файлами

| Операция | Клавиши/команда |
|---|---|
| Copy/yank | `y` |
| Cut | `x` |
| Paste | `p` |
| Paste overwrite | `P` |
| Cancel yank state | `Y`/`X` |
| Rename | `r` |
| Create file | `a` |
| Create directory | `a`, имя должно заканчиваться на `/` |
| Delete/trash | `d` |
| Hard delete | `D` |
| Absolute symlink | `-` |
| Relative symlink | `_` |
| chmod | VERIFY: не указан в `man yazi` preset keybindings |
| Bulk rename | VERIFY, возможно через editor plugin/opener |

Практическое правило: если операция опасна, сначала проверь выбранные файлы и ищи confirmation prompt. Для неуверенного удаления предпочитай trash, а не hard delete.

## Поиск

Yazi preset keybindings используют установленные `fd`, `rg`, `fzf`:

| Клавиша | Действие |
|---|---|
| `s` | search files by name через `fd` |
| `S` | search files by content/name через `rg` |
| `z` | jump через `zoxide` |
| `Z` | jump/reveal через `fzf` |

Fallback:

```bash
fd pattern ~/Downloads
rg "text" ~/Downloads
nvim "$(fd pattern | fzf)"
yazi "$(dirname "$(fd pattern | fzf)")"
```

## Архивы

Открытие archive preview зависит от Yazi backend.

Fallback:

```bash
7z l archive.zip
7z x archive.zip
7z a archive.7z folder/
unzip archive.zip
```

## Clipboard

Yazi имеет внутренний clipboard для file operations; системный Wayland clipboard - `wl-copy/wl-paste`.

```bash
printf '%s\n' "$PWD/file" | wl-copy
wl-paste
```

Копирование путей по `man yazi`:

| Клавиши | Что копирует |
|---|---|
| `cc` | absolute path |
| `cd` | parent directory path |
| `cf` | file name |
| `cn` | file name without extension |

## Tabs

Tabs полезны для работы между несколькими директориями: Downloads, project, external drive.

| Действие | Клавиши |
|---|---|
| New tab | `t` |
| Close tab | `Ctrl+c`/custom VERIFY |
| Switch to tab | `1..9` |
| Previous/next tab | `[` / `]` |
| Swap tab previous/next | `{` / `}` |

## Командная строка Yazi

По `man yazi`:

| Клавиша | Действие |
|---|---|
| `;` | run shell command |
| `:` | run shell command and block UI until command finishes |

Fallback: открой terminal в нужной папке или выйди из Yazi и выполни команду.

## Preview

- Markdown/text: должен показываться как текст.
- Images: зависит от kitty graphics protocol и preview tools.
- PDF: нужен preview extractor.
- Archives: нужен `7z`/backend.

Диагностика:

```bash
yazi --debug
file path
bat path
7z l archive
```

## Конфиги

Стандартные файлы:

```bash
~/.config/yazi/yazi.toml
~/.config/yazi/keymap.toml
~/.config/yazi/theme.toml
```

Сейчас `~/.config/yazi` отсутствует. Если решишь настраивать Yazi, лучше добавить файлы через Home Manager `xdg.configFile`, чтобы они жили в repo.

## Plugins/packages

Yazi поддерживает плагины и интеграции. Не устанавливайте их без отдельной причины: сначала опишите сценарий, затем добавьте зависимость в Nix/Home Manager и документацию.

## Практические сценарии

Разобрать Downloads:

```bash
yazi ~/Downloads
```

Найти NixOS config:

```bash
z nixos
yazi .
```

Скопировать файл: выберите файл, `y`, перейдите в цель, `p`.

Переименовать пачку файлов: если bulk rename не настроен, используйте shell, `vidir` если установлен, или аккуратный script после dry run.

Удалить мусор через trash: используйте Yazi trash-delete, если настроено; fallback:

```bash
trash-put file
trash-list
trash-restore
```

Открыть terminal в текущей папке: проще выйти из Yazi в нужной директории через shell wrapper с `--cwd-file` VERIFY; без wrapper используйте `pwd`/ручной `cd`.

Выбрать файл и открыть в nvim:

```bash
nvim "$(fd . | fzf)"
```

Найти большой файл:

```bash
dust .
fd -t f . | xargs -r du -h | sort -h | tail
```

Флешка/внешний диск:

```bash
lsblk
duf
yazi /mnt
```

UDisks and the user-level `udiskie` service automatically mount removable
filesystems below `/run/media/ilya/<label>`. A lifecycle hook creates a
compatibility symlink at `/mnt/<label>` and removes it after unmount, so the
usual `yazi /mnt` workflow remains available. Safe unmount/eject should be done
through Dolphin or the udiskie tray icon. Yazi itself does not mount devices;
it only opens the compatibility path.

The SMB share is a separate automount at `/vault`, so scans of `/mnt` never
touch it. On Wi-Fi SSID `0xDEADBEEF48`, accessing `/vault` directly permits the
normal CIFS attempt. In any other network session, the first access sends one
one-second ping to `192.168.0.10`; a failed result is cached until the network
changes or reconnects, and later accesses do not retry the ping or CIFS.

## Troubleshooting

- Yazi не открывает файл: проверь opener и `xdg-open file`.
- Preview пустой: `yazi --debug`, `file path`, `bat path`.
- Нет icons: проверь Nerd Font в kitty.
- Странные символы: проверь locale и font.
- Проблемы с terminal: проверь `kitty`, `$TERM`, `$EDITOR`.
- Trash не работает: проверь `trash-put`, права на filesystem.
- Clipboard не работает: проверь `wl-copy`, `wl-paste`.

## Большая таблица keybindings

| Клавиши | Действие | Статус |
|---|---|---|
| `j/k` | вниз/вверх | подтверждено `man yazi` |
| `h/l` | parent/enter directory | подтверждено `man yazi` |
| `o`/`Enter` | open | подтверждено `man yazi` |
| `Space` | select | подтверждено `man yazi` |
| `Ctrl+a` | select all | подтверждено `man yazi` |
| `Ctrl+r` | invert selection | подтверждено `man yazi` |
| `v`/`V` | visual select/unset | подтверждено `man yazi` |
| `Esc` | cancel selection | подтверждено `man yazi` |
| `y` | yank/copy | подтверждено `man yazi` |
| `x` | cut | подтверждено `man yazi` |
| `p`/`P` | paste / paste overwrite | подтверждено `man yazi` |
| `r` | rename | подтверждено `man yazi` |
| `d`/`D` | trash / permanent delete | подтверждено `man yazi` |
| `a` | create file/directory | подтверждено `man yazi` |
| `-`/`_` | absolute/relative symlink | подтверждено `man yazi` |
| `/`/`?` | forward/backward find | подтверждено `man yazi` |
| `n`/`N` | next/previous occurrence | подтверждено `man yazi` |
| `s`/`S` | search via fd/rg | подтверждено `man yazi` |
| `f` | filter | подтверждено `man yazi` |
| `.` | hidden files | подтверждено `man yazi` |
| `t` | new tab | подтверждено `man yazi` |
| `1..9` | tab switch | подтверждено `man yazi` |
| `[`/`]` | previous/next tab | подтверждено `man yazi` |
| `cc`/`cd`/`cf`/`cn` | copy paths/names | подтверждено `man yazi` |
| `q` | quit | дефолт, VERIFY |
| `?` | help | дефолт, VERIFY |

## Cheatsheet

```bash
yazi
yazi .
yazi ~/Downloads
yazi --debug
fd pattern | fzf
trash-put file
7z x archive.zip
```
