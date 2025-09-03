FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-pgsql \
    php8.2-sqlite3 \
    php8.2-curl \
    nginx \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/start_adminer.sh /start_adminer.sh
RUN chmod +x /start_adminer.sh

WORKDIR /var/www/html

EXPOSE 8080

CMD ["/start_adminer.sh"]