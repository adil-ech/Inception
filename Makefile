NAME = inception

all: up

up:
	docker compose -f srcs/docker-compose.yml up --build -d

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	docker compose -f srcs/docker-compose.yml down -v --rmi all --remove-orphans

fclean: clean
	docker system prune -af

re: fclean all
