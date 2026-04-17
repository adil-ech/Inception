FROM debian:bookworm

RUN apt update && apt install -y mariadb-server mariadb-client

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306

CMD ["/script.sh"]
