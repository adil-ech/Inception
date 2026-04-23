#!/bin/bash

until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USR" -p"$MYSQL_PSWD" --silent; do
    sleep 2
done

cd /var/www/html

wget https://wordpress.org/latest.tar.gz

tar -xzvf latest.tar.gz

mv wordpress/* .

cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/$MYSQL_DTBS/g" wp-config.php
sed -i "s/username_here/$MYSQL_USR/g" wp-config.php
sed -i "s/password_here/$MYSQL_PSWD/g" wp-config.php
sed -i "s/localhost/$MYSQL_HOST/g" wp-config.php

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec php-fpm8.2 -F
