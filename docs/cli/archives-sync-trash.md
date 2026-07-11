# Archives, sync, trash

## Назначение

Работа с архивами, безопасным удалением и синхронизацией директорий.

## trash-cli

```bash
trash-put file
trash-list
trash-restore
trash-empty
```

Используйте вместо `rm`, если не уверены. Не делайте опасный alias `rm=trash-put` без понимания: scripts могут ожидать поведение настоящего `rm`.

## p7zip / 7z

```bash
7z l archive.zip
7z x archive.zip
7z a archive.7z folder/
7z a archive.zip file1 file2
```

Работает с zip/rar/7z/tar в зависимости от поддержки формата.

## unzip

```bash
unzip file.zip
unzip -l file.zip
unzip file.zip -d target/
```

## rsync

Trailing slash важен:

```bash
rsync -avh source/ target/   # содержимое source в target
rsync -avh source target/    # директория source внутри target
```

Dry run:

```bash
rsync -avhn --delete source/ target/
```

Progress:

```bash
rsync -avh --progress source/ target/
```

Backup:

```bash
rsync -avh --delete ~/Documents/ /mnt/backup/Documents/
```

## rclone

`rclone` не найден в текущих пакетах. Это optional инструмент для облаков и remote storage.

## Cheatsheet

```bash
trash-put file
trash-list
7z x archive.7z
7z a backup.7z folder/
unzip file.zip
rsync -avhn --delete src/ dst/
```
