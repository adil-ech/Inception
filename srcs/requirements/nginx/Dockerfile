FROM debian:bookworm

RUN apt update && apt install -y nginx openssl

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /etc/nginx/ssl

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
   -keyout /etc/nginx/ssl/nginx.key \
   -out /etc/nginx/ssl/nginx.crt \
   -subj "/C=MA/ST=Khouribga/L=Khouribga/O=42/OU=1337/CN=localhost"
