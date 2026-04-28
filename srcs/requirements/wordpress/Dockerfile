FROM debian:bookworm

RUN apt update && apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-redis wget curl mariadb-client

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 9000

CMD ["/script.sh"]
