FROM debian:bookworm

RUN apt-get update && apt-get install -y \
	php8.2-fpm \
	php8.2-mysql \
	php8.2-curl \
	php8.2-gd \
	php8.2-intl \
	php8.2-mbstring \
	php8.2-soap \
	php8.2-xml \
	php8.2-xmlrpc \
	php8.2-zip \
	curl \
	wget \
	mariadb-client \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -o /tmp/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /tmp/wp-cli.phar \
	&& mv /tmp/wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/setup_wordpress.sh /setup_wordpress.sh
RUN chmod +x /setup_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/setup_wordpress.sh"]
