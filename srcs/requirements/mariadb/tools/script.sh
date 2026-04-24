#!/bin/bash

mysqld_safe &

until mysqladmin ping -h localhost --silent; do
 sleep 2
done

mysql -u root -h localhost << EOF
CREATE DATABASE IF NOT EXISTS $MYSQL_DTBS;
CREATE USER IF NOT EXISTS '$MYSQL_USR'@'%' IDENTIFIED BY '$MYSQL_PSWD';
GRANT ALL PRIVILEGES ON $MYSQL_DTBS.* TO '$MYSQL_USR'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PSWD';
FLUSH PRIVILEGES;
EOF

wait