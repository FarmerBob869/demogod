# Makefile for notclal Insurance Agent Database

.PHONY: help setup start stop restart logs clean backup restore shell

# Default target
help:
	@echo "notclal Insurance Agent Database Management"
	@echo "=========================================="
	@echo "Available commands:"
	@echo "  make setup      - Initial setup (create secrets and directories)"
	@echo "  make start      - Start database containers"
	@echo "  make stop       - Stop database containers"
	@echo "  make restart    - Restart database containers"
	@echo "  make logs       - View container logs"
	@echo "  make clean      - Stop containers and remove volumes (WARNING: data loss)"
	@echo "  make backup     - Backup database"
	@echo "  make restore    - Restore database from backup"
	@echo "  make shell      - Open PostgreSQL shell"
	@echo "  make test       - Test database connection"

# Initial setup
setup:
	@echo "Setting up notclal Insurance Agent database..."
	@chmod +x scripts/setup-secrets.sh
	@./scripts/setup-secrets.sh
	@mkdir -p database/init database/backups
	@cp database/schema.sql database/init/02-schema.sql 2>/dev/null || true
	@cp database/prompts.sql database/init/03-prompts.sql 2>/dev/null || true
	@echo "Setup complete!"

# Start containers
start:
	@echo "Starting database containers..."
	@docker-compose up -d
	@echo "Waiting for database to be ready..."
	@sleep 5
	@docker-compose ps
	@echo "Database started successfully!"

# Stop containers
stop:
	@echo "Stopping database containers..."
	@docker-compose down
	@echo "Database stopped!"

# Restart containers
restart: stop start

# View logs
logs:
	@docker-compose logs -f

# Clean everything (WARNING: removes data)
clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? (y/N) " confirm && \
	if [ "$$confirm" = "y" ]; then \
		docker-compose down -v; \
		rm -rf database/backups/*; \
		echo "Cleanup complete!"; \
	else \
		echo "Cleanup cancelled."; \
	fi

# Backup database
backup:
	@echo "Creating database backup..."
	@BACKUP_FILE="database/backups/backup_$$(date +%Y%m%d_%H%M%S).sql" && \
	docker-compose exec -T postgres pg_dump -U notclal_admin notclal_insurance > $$BACKUP_FILE && \
	echo "Backup created: $$BACKUP_FILE"

# Restore database from latest backup
restore:
	@echo "Available backups:"
	@ls -la database/backups/*.sql 2>/dev/null || echo "No backups found"
	@read -p "Enter backup filename (or press Enter for latest): " backup_file; \
	if [ -z "$$backup_file" ]; then \
		backup_file=$$(ls -t database/backups/*.sql 2>/dev/null | head -1); \
	fi; \
	if [ -f "$$backup_file" ]; then \
		echo "Restoring from: $$backup_file"; \
		docker-compose exec -T postgres psql -U notclal_admin notclal_insurance < $$backup_file; \
		echo "Restore complete!"; \
	else \
		echo "Backup file not found!"; \
	fi

# Open PostgreSQL shell
shell:
	@docker-compose exec postgres psql -U notclal_admin -d notclal_insurance

# Test database connection
test:
	@echo "Testing database connection..."
	@docker-compose exec postgres pg_isready -U notclal_admin -d notclal_insurance && \
	echo "Database connection successful!" || \
	echo "Database connection failed!"