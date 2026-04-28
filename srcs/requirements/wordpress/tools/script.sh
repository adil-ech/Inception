#!/bin/bash

set -e

until mysqladmin ping -h "$MYSQL_HOST" --silent; do
    sleep 2
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz

    cp -r wordpress/* .
    rm -rf wordpress latest.tar.gz

    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$MYSQL_DTBS/g" wp-config.php
    sed -i "s/username_here/$MYSQL_USR/g" wp-config.php
    sed -i "s/password_here/$MYSQL_PSWD/g" wp-config.php
    sed -i "s/localhost/$MYSQL_HOST/g" wp-config.php
    
    #redis config
    sed -i "/<?php/a\\
define('WP_REDIS_HOST', 'redis');\\
define('WP_REDIS_PORT', 6379);\\
define('WP_REDIS_TIMEOUT', 1);\\
define('WP_REDIS_READ_TIMEOUT', 1);\\
define('WP_REDIS_DATABASE', 0);" wp-config.php
    
    wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    
    wp plugin install redis-cache --activate --allow-root
    
    wp redis enable --allow-root
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec php-fpm8.2 -F