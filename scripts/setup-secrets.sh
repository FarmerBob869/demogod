#!/bin/bash

# Setup Docker secrets for notclal Insurance Agent
# This script creates secure password files for PostgreSQL and PgAdmin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up Docker secrets for notclal Insurance Agent...${NC}"

# Create secrets directory
SECRETS_DIR="./secrets"
if [ ! -d "$SECRETS_DIR" ]; then
    echo -e "${YELLOW}Creating secrets directory...${NC}"
    mkdir -p "$SECRETS_DIR"
    chmod 700 "$SECRETS_DIR"
fi

# Function to generate secure password
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-25
}

# Create PostgreSQL password
if [ ! -f "$SECRETS_DIR/postgres_password.txt" ]; then
    echo -e "${YELLOW}Generating PostgreSQL password...${NC}"
    POSTGRES_PASSWORD=$(generate_password)
    echo -n "$POSTGRES_PASSWORD" > "$SECRETS_DIR/postgres_password.txt"
    chmod 600 "$SECRETS_DIR/postgres_password.txt"
    echo -e "${GREEN}PostgreSQL password created${NC}"
else
    echo -e "${YELLOW}PostgreSQL password already exists${NC}"
fi

# Create PgAdmin password
if [ ! -f "$SECRETS_DIR/pgadmin_password.txt" ]; then
    echo -e "${YELLOW}Generating PgAdmin password...${NC}"
    PGADMIN_PASSWORD=$(generate_password)
    echo -n "$PGADMIN_PASSWORD" > "$SECRETS_DIR/pgadmin_password.txt"
    chmod 600 "$SECRETS_DIR/pgadmin_password.txt"
    echo -e "${GREEN}PgAdmin password created${NC}"
else
    echo -e "${YELLOW}PgAdmin password already exists${NC}"
fi

# Create .env file from .env.example if it doesn't exist
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
    echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
    cp .env.example .env
    
    # Add the PostgreSQL password to .env for application use
    if [ -f "$SECRETS_DIR/postgres_password.txt" ]; then
        POSTGRES_PASSWORD=$(cat "$SECRETS_DIR/postgres_password.txt")
        echo "" >> .env
        echo "# Auto-generated password (DO NOT COMMIT)" >> .env
        echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" >> .env
    fi
    
    echo -e "${GREEN}.env file created${NC}"
else
    echo -e "${YELLOW}.env file already exists${NC}"
fi

# Display connection information
echo -e "\n${GREEN}=== Setup Complete ===${NC}"
echo -e "${GREEN}PostgreSQL will be available at:${NC} localhost:5432"
echo -e "${GREEN}PgAdmin will be available at:${NC} http://localhost:5050"
echo -e "${GREEN}Database name:${NC} notclal_insurance"
echo -e "${GREEN}Database user:${NC} notclal_admin"
echo -e "\n${YELLOW}Note: Passwords are stored securely in the secrets directory${NC}"
echo -e "${YELLOW}Never commit the secrets directory or .env file to version control!${NC}"