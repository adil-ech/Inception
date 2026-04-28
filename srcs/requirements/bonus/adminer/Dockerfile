FROM debian:bookworm

RUN apt update && apt install -y php8.2 php8.2-mysqli php8.2-pdo php8.2-pdo-mysql wget

RUN mkdir -p /var/www/adminer

RUN wget -O /var/www/adminer/index.php \
    https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php

COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

WORKDIR /var/www/adminer

EXPOSE 8080

CMD ["script.sh"]
