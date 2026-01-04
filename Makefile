.PHONY: help up down restart logs clean backup restore shell status

# Default target
help:
	@echo "Docker Deep Dive - Available Commands"
	@echo "======================================"
	@echo "make up          - Start all services"
	@echo "make down        - Stop all services"
	@echo "make restart     - Restart all services"
	@echo "make logs        - View logs (all services)"
	@echo "make logs-wp     - View WordPress logs"
	@echo "make logs-db     - View database logs"
	@echo "make clean       - Stop and remove all data (⚠️  destructive)"
	@echo "make backup      - Backup database"
	@echo "make restore     - Restore database from backup"
	@echo "make shell-wp    - Open shell in WordPress container"
	@echo "make shell-db    - Open MySQL shell"
	@echo "make status      - Show container status"
	@echo "make validate    - Validate docker-compose.yml"

# Start services
up:
	@echo "Starting Docker Deep Dive services..."
	docker compose up -d
	@echo ""
	@echo "✅ Services started!"
	@echo "WordPress:  http://localhost:8080"
	@echo "phpMyAdmin: http://localhost:8081"

# Stop services
down:
	@echo "Stopping services..."
	docker compose down

# Restart services
restart:
	@echo "Restarting services..."
	docker compose restart

# View logs
logs:
	docker compose logs -f

logs-wp:
	docker compose logs -f wordpress

logs-db:
	docker compose logs -f db

# Clean everything (dangerous!)
clean:
	@echo "⚠️  This will delete ALL data including the database!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		rm -rf wp-content/; \
		echo "✅ Cleaned successfully"; \
	else \
		echo "❌ Cancelled"; \
	fi

# Backup database
backup:
	@mkdir -p backups
	@echo "Creating database backup..."
	@docker exec -e MYSQL_PWD=wordpress ddd_mysql mysqldump -u wordpress wordpress > backups/backup-$$(date +%Y%m%d-%H%M%S).sql
	@echo "✅ Backup created in backups/"

# Restore database
restore:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make restore FILE=backups/backup-YYYYMMDD-HHMMSS.sql"; \
		exit 1; \
	fi
	@echo "Restoring database from $(FILE)..."
	@docker exec -i -e MYSQL_PWD=wordpress ddd_mysql mysql -u wordpress wordpress < $(FILE)
	@echo "✅ Database restored"

# Open shell in WordPress container
shell-wp:
	docker exec -it ddd_wordpress bash

# Open MySQL shell
shell-db:
	docker exec -it -e MYSQL_PWD=wordpress ddd_mysql mysql -u wordpress wordpress

# Show container status
status:
	@echo "Container Status:"
	@echo "================="
	@docker compose ps

# Validate configuration
validate:
	@echo "Validating docker-compose.yml..."
	@docker compose config --quiet && echo "✅ Configuration is valid"
