all: up

up:
	mkdir -p $(HOME)/data/db
	mkdir -p $(HOME)/data/wordpress
	mkdir -p $(HOME)/data/gitea
	docker-compose -f srcs/docker-compose.yml up --build -d

down:
	docker-compose -f srcs/docker-compose.yml down

clean: down
	docker system prune -af
	rm -rf $(HOME)/data
fclean: clean
	docker-compose -f srcs/docker-compose.yml down -v --rmi all --remove-orphans
	docker system prune -af --volumes
re: clean all
