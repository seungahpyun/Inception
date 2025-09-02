all:
	cd srcs && docker compose up --build

down:
	cd srcs && docker compose down

clean: down
	docker system prune -af

clean-project: down
	cd srcs && docker compose down -v --remove-orphans
	docker system prune -f

fclean: down
	cd srcs && docker compose down -v
	docker system prune -af --volumes
	docker volume prune -f

re: clean all

.PHONY: all down clean clean-project fclean re
