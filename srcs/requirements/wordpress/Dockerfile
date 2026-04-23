FROM debian:bookworm

RUN apt update && apt install -y php php-fpm php-mysql wget curl mariadb-client

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 9000

CMD ["/script.sh"]
