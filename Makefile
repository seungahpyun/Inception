USER := $(shell whoami)

env:
	@if [ ! -f "srcs/.env" ]; then \
		sed 's/LOGIN/$(USER)/g' srcs/.env.example > srcs/.env; \
	fi

secrets:
	@if [ ! -d "secrets" ]; then \
		mkdir -p secrets; \
		openssl rand -base64 16 | tr -d '\n' > secrets/db_root_password.txt; \
		openssl rand -base64 16 | tr -d '\n' > secrets/db_password.txt; \
		openssl rand -base64 16 | tr -d '\n' > secrets/wp_admin_password.txt; \
		openssl rand -base64 16 | tr -d '\n' > secrets/wp_user_password.txt; \
		chmod 600 secrets/*.txt; \
	fi

setup:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mysql

all: env secrets setup
	@cd srcs && HOME=/home/$(USER) docker compose up --build

down:
	@cd srcs && docker compose down

clean: down
	@docker system prune -af

fclean: down
	@cd srcs && docker compose down -v
	@docker system prune -af --volumes
	@sudo rm -rf /home/$(USER)/data
	@rm -rf srcs/.env
	@rm -rf secrets

re: fclean all

.PHONY: all down setup secrets env clean fclean re
