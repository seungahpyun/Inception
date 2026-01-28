USER := $(shell whoami)

env:
	@if [ ! -f "srcs/.env" ]; then \
		echo "Creating .env file for user: $(USER)"; \
		sed 's/LOGIN/$(USER)/g' srcs/.env.example > srcs/.env; \
		echo ".env file created"; \
	else \
		echo ".env file already exists"; \
	fi

secrets:
	@if [ ! -d "secrets" ]; then \
		mkdir -p secrets; \
		echo "Creating secrets..."; \
		openssl rand -base64 16 | tr -d '\n' > secrets/db_root_password.txt; \
		openssl rand -base64 16 | tr -d '\n' > secrets/db_password.txt; \
		openssl rand -base64 16 | tr -d '\n' > secrets/wp_admin_password.txt; \
		openssl rand -base64 16 | tr -d '\n' > secrets/wp_user_password.txt; \
		chmod 600 secrets/*.txt; \
		echo "Secrets created successfully!"; \
	else \
		echo "Secrets directory already exists. Skipping secret generation."; \
	fi

setup:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mysql
	@echo "Data directories created successfully!"

all: secrets setup
	cd srcs && docker compose up --build

down:
	cd srcs && docker compose down

clean: down
	docker system prune -af

fclean: down
	cd srcs && docker compose down -v
	docker system prune -af --volumes

re: fclean all

.PHONY: all down setup secrets clean fclean re
