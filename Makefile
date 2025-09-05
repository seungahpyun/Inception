all:
	cd srcs && docker compose up --build

down:
	cd srcs && docker compose down

clean: down
	docker system prune -af

fclean: down
	cd srcs && docker compose down -v
	docker system prune -af --volumes

re: clean all

.PHONY: all down clean fclean re