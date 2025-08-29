FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /init_db.sh

RUN chmod +x /init_db.sh

RUN mkdir -p /var/lib/mysql && \
    chown -R mysql:mysql /var/lib/mysql

EXPOSE 3306

CMD ["/init_db.sh"]