#!/bin/bash

cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp core download --allow-root

    wp config create \
        --dbname=wordpress \
        --dbuser=wpuser \
        --dbpass=wppassword \
        --dbhost=mariadb:3306 \
        --allow-root

    wp core install \
        --url=localhost \
        --title="Inception WordPress" \
        --admin_user=admin \
        --admin_password=adminpass \
        --admin_email=admin@example.com \
        --allow-root

    wp user create wpuser wpuser@example.com \
        --user_pass=wpuserpass \
        --role=editor \
        --allow-root
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

php-fpm8.2 -F
