FROM debian:bookworm

RUN apt update && apt install -y python3

COPY www/ /var/www/html/

WORKDIR /var/www/html/

EXPOSE 80

CMD ["python3", "-m", "http.server", "80", "--bind", "0.0.0.0"]
