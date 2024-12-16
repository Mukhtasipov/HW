#!/bin/bash

WEB_SERVER_IP="192.168.0.200"
WEB_SERVER_PORT=80
INDEX_FILE="/var/www/html/index.nginx-debian.html"

# Проверка доступности порта
if ! nc -z $WEB_SERVER_IP $WEB_SERVER_PORT; then
    echo "Порт $WEB_SERVER_PORT недоступен"
    exit 1
fi

# Проверка существования файла index.nginx-debian.html
if [ ! -f $INDEX_FILE ]; then
    echo "Файл $INDEX_FILE отсутствует"
    exit 1
fi

exit 0
