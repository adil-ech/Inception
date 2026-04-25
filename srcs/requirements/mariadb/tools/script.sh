#!/bin/bash
set -e

mysqld_safe --skip-networking &
MYSQL_PID=$!

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

mysqladmin -u root -p"$MYSQL_ROOT_PSWD" shutdown

exec mysqld_safe