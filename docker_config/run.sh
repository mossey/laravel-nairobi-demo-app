#!/bin/bash



echo "APP_KEY="  ${APP_KEY} >> .env
echo "APP_DEBUG="${APP_DEBUG} >> .env
echo "APP_LOG_LEVEL="${APP_LOG_LEVEL} >> .env
echo "APP_NAME="${APP_NAME} >> .env
echo "DB_CONNECTION="${DB_CONNECTION} >> .env
echo "DB_HOST="${DB_HOST} >> .env
echo "DB_PORT="${DB_PORT} >> .env
echo "DB_DATABASE="${DB_DATABASE} >> .env
echo "DB_USERNAME="${DB_USERNAME} >> .env
echo "DB_PASSWORD="${DB_PASSWORD} >> .env




php artisan config:cache
php artisan route:cache
composer dumpautoload -o


chmod -R 777  storage
unset APP_KEY
/usr/sbin/apache2ctl start
tail -f storage/logs/laravel.log
