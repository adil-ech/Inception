#!/bin/bash

service mariadb start
until mysqladmin ping -h 127.0.0.1 --silent; do
 sleep 1
done

mysql -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DTBS;"

mysql -e "CREATE USER IF NOT EXISTS '$MYSQL_USR'@'%' IDENTIFIED BY '$MYSQL_PSWD';"

mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DTBS.* TO '$MYSQL_USR'@'%';"

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PSWD';"

mysql -e "FLUSH PRIVILEGES;"

service mariadb stop

exec mysqld_safe
