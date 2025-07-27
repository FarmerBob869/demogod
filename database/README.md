# notclal Insurance Agent - Database Setup

## 🚀 Quick Start

```bash
# 1. Initial setup (creates secrets and directories)
make setup

# 2. Start the database
make start

# 3. Verify it's running
make test
```

## 📋 Prerequisites

- Docker and Docker Compose installed
- Make command available (optional but recommended)
- SCRUM-6 files (`schema.sql` and `prompts.sql`) in the `database/` directory

## 🔧 Manual Setup (without Make)

```bash
# 1. Create secrets
chmod +x scripts/setup-secrets.sh
./scripts/setup-secrets.sh

# 2. Copy SCRUM-6 files to init directory
mkdir -p database/init
cp database/schema.sql database/init/02-schema.sql
cp database/prompts.sql database/init/03-prompts.sql

# 3. Start containers
docker-compose up -d

# 4. Check status
docker-compose ps
```

## 🗄️ Database Access

### PostgreSQL Connection
- **Host**: localhost
- **Port**: 5432
- **Database**: notclal_insurance
- **Username**: notclal_admin
- **Password**: (see `secrets/postgres_password.txt`)

### PgAdmin Access
- **URL**: http://localhost:5050
- **Email**: admin@notclal.com
- **Password**: (see `secrets/pgadmin_password.txt`)

### Connect via CLI
```bash
# Using make
make shell

# Or directly
docker-compose exec postgres psql -U notclal_admin -d notclal_insurance
```

## 📊 Database Schema

The database includes:

1. **From SCRUM-6**:
   - `agent_prompts` - Claude AI prompts with versioning
   
2. **Additional Tables**:
   - `conversations` - Track chat sessions
   - `messages` - Store conversation messages

## 🔒 Security

- Passwords are stored in Docker secrets (never commit these!)
- All sensitive files are in `.gitignore`
- Database runs in isolated Docker network
- Health checks ensure service availability

## 🛠️ Common Commands

```bash
# View logs
make logs

# Stop database
make stop

# Restart database
make restart

# Create backup
make backup

# Restore from backup
make restore

# Clean everything (WARNING: removes all data)
make clean
```

## 🐛 Troubleshooting

### Container won't start
```bash
# Check logs
docker-compose logs postgres

# Verify file permissions
ls -la secrets/
ls -la database/init/
```

### Connection refused
```bash
# Check if container is running
docker-compose ps

# Test connection
make test

# Check port availability
lsof -i :5432
```

### Permission errors
```bash
# Fix permissions
chmod 700 secrets/
chmod 600 secrets/*.txt
chmod +x scripts/*.sh
```

## 📁 Directory Structure

```
notclal-insurance-agent/
├── docker-compose.yml       # Container configuration
├── .env.example            # Environment template
├── .env                    # Local environment (don't commit!)
├── Makefile                # Convenience commands
├── scripts/
│   └── setup-secrets.sh    # Secret generation script
├── secrets/                # Docker secrets (don't commit!)
│   ├── postgres_password.txt
│   └── pgadmin_password.txt
└── database/
    ├── README.md           # This file
    ├── schema.sql          # SCRUM-6 schema
    ├── prompts.sql         # SCRUM-6 prompts
    ├── init/               # Container initialization
    │   ├── 01-init.sql
    │   ├── 02-schema.sql   # Copy of schema.sql
    │   └── 03-prompts.sql  # Copy of prompts.sql
    └── backups/            # Database backups
```

## 🔄 Integration with FastAPI

The database is ready for FastAPI integration:

```python
# Example connection string
DATABASE_URL = "postgresql://notclal_admin:password@localhost:5432/notclal_insurance"
```

## 📝 Notes

- The database automatically loads SCRUM-6 schema and prompts on first start
- Additional tables for conversation logging are created automatically
- PgAdmin is included for easy database management
- All data persists in Docker volumes between restarts