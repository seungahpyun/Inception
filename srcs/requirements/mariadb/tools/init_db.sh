#!/bin/bash

DB_ROOT_PASS=$(cat /run/secrets/db_root_password | tr -d '\n\r')
DB_PASS=$(cat /run/secrets/db_password | tr -d '\n\r')

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "Initializing MariaDB database..."
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	FIRST_RUN=true
else
	echo "MariaDB database already exists"
	FIRST_RUN=false
fi

mysqld_safe --user=mysql --datadir=/var/lib/mysql &
MYSQL_PID=$!

while ! mysqladmin ping -hlocalhost --silent; do
	echo "Waiting for MariaDB to start..."
	sleep 2
done

echo "MariaDB is ready!"

if [ "$FIRST_RUN" = true ]; then
	echo "First run - Setting up database..."
	mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF
	echo "Database setup completed!"
else
	echo "Existing database - Recreating user..."
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
	echo "User and database recreated!"
fi

echo "Testing connection..."
if mysql -u ${MYSQL_USER} -p${DB_PASS} ${MYSQL_DATABASE} -e "SELECT 1;" > /dev/null 2>&1; then
	echo "✅ Connection test successful!"
else
	echo "❌ Connection test failed!"
	mysql -u root -p${DB_ROOT_PASS} -e "SHOW DATABASES; SELECT User, Host FROM mysql.user WHERE User='${MYSQL_USER}';"
fi

wait $MYSQL_PID
