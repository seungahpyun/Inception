#!/bin/bash

DB_ROOT_PASS=$(cat /run/secrets/db_root_password | tr -d '\n\r')
DB_PASS=$(cat /run/secrets/db_password | tr -d '\n\r')

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

while ! mysqladmin ping -hlocalhost --silent; do
	sleep 1
done

if mysql -u root -e "SELECT 1" 2>/dev/null; then
	mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
else
	mysql -u root -p${DB_ROOT_PASS} << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
DROP USER IF EXISTS '${MYSQL_USER}'@'%';
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

mysqladmin -u root -p${DB_ROOT_PASS} shutdown
wait $MYSQL_PID

exec mysqld_safe --user=mysql --datadir=/var/lib/mysql
