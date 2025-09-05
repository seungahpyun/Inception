#!/bin/bash

DB_ROOT_PASS=$(cat /run/secrets/db_root_password | tr -d '\n\r')
DB_PASS=$(cat /run/secrets/db_password | tr -d '\n\r')

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	FIRST_RUN=true
else
	echo "MariaDB database already exists, skipping initialization..."
	FIRST_RUN=false
fi

mysqld_safe --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

while ! mysqladmin ping -hlocalhost --silent; do
	echo "Waiting for MariaDB to start..."
	sleep 2
done

if [ "$FIRST_RUN" = true ]; then
	echo "Setting up database and users..."
	mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
	echo "Database setup completed!"
else
	echo "Database already configured, ensuring user permissions..."
	mysql -u root -p${DB_ROOT_PASS} << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

echo "Database initialized successfully!"

wait $MYSQL_PID