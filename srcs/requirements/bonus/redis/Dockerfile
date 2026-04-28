FROM debian:bookworm

RUN apt update && apt install -y redis-server

COPY conf/redis.conf /etc/redis/redis.conf

RUN mkdir -p /var/lib/redis var/log/redis && chown -R redis:redis /var/lib/redis /var/log/redis

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.conf", "--daemonize no"]
