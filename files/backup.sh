#!/bin/bash

# Переменные
SRC_DIR="$HOME/"
DEST_DIR="/tmp/backup"
LOG_FILE="/tmp/backup/backup.log"

# Команда rsync для зеркального копирования
rsync -avz --delete --checksum --progress "$SRC_DIR" "$DEST_DIR"

# Проверка статуса выполнения rsync и запись в лог
if [ $? -eq 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup completed successfully." >> "$LOG_FILE"
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Backup failed!" >> "$LOG_FILE"
fi
