FROM debian:bookworm

RUN apt update && apt install -y vsftpd

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf

COPY tools/script.sh /usr/local/bin/script.sh
RUN chmod +x /usr/local/bin/script.sh

EXPOSE 21 21000-21010

CMD ["script.sh"]