#!/bin/bash

cd /var/www/html

DB_PASS=$(cat /run/secrets/db_password | tr -d '\n\r')
WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_password | tr -d '\n\r')
WP_USER_PASS=$(cat /run/secrets/wp_user_password | tr -d '\n\r')

if [ ! -f wp-config.php ]; then
	wp core download --allow-root

	wp config create \
		--dbname=${MYSQL_DATABASE} \
		--dbuser=${MYSQL_USER} \
		--dbpass=${DB_PASS} \
		--dbhost=${MYSQL_HOST}:3306 \
		--allow-root

	wp core install \
		--url=${WP_URL} \
		--title="${WP_TITLE}" \
		--admin_user=${WP_ADMIN_USER} \
		--admin_password=${WP_ADMIN_PASS} \
		--admin_email=${WP_ADMIN_EMAIL} \
		--allow-root

	wp user create ${WP_USER} ${WP_USER_EMAIL} \
		--user_pass=${WP_USER_PASS} \
		--role=editor \
		--allow-root
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

php-fpm8.2 -F
