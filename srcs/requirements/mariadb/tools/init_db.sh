#!/bin/bash

mysql_install_db --user=mysql --datadir=/var/lib/mysql

mysqld_safe --user=mysql --datadir=/var/lib/mysql &

while ! mysqladmin ping -hlocalhost --silent; do
	echo "Waiting for MariaDB to start..."
	sleep 2
done


mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
mysql -e "CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY 'wppassword';"
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'rootpassword';"
mysql -e "FLUSH PRIVILEGES;"

echo "Database initialized successfully!"

wait
