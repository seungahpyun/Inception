all:
	cd srcs && docker compose up --build

down:
	cd srcs && docker compose down

clean: down
	docker system prune -af

re: clean all

.PHONY: all down clean re