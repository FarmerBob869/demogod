-- Database initialization script for notclal Insurance Agent
-- This script runs automatically when the PostgreSQL container starts

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS notclal;

-- Set default search path
SET search_path TO notclal, public;

-- Import SCRUM-6 schema
\i /docker-entrypoint-initdb.d/02-schema.sql

-- Import SCRUM-6 prompts
\i /docker-entrypoint-initdb.d/03-prompts.sql

-- Create additional tables for conversation logging
CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    conversation_id VARCHAR(255) UNIQUE NOT NULL,
    user_id VARCHAR(255),
    channel VARCHAR(50) NOT NULL DEFAULT 'slack',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    status VARCHAR(50) DEFAULT 'active',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS messages (
    id SERIAL PRIMARY KEY,
    conversation_id VARCHAR(255) NOT NULL REFERENCES conversations(conversation_id),
    message_id VARCHAR(255) UNIQUE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX idx_conversations_user_id ON conversations(user_id);
CREATE INDEX idx_conversations_status ON conversations(status);
CREATE INDEX idx_conversations_created_at ON conversations(created_at);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_timestamp ON messages(timestamp);

-- Create trigger for updated_at on conversations
CREATE OR REPLACE FUNCTION update_conversations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conversations_updated_at_trigger
    BEFORE UPDATE ON conversations
    FOR EACH ROW
    EXECUTE FUNCTION update_conversations_updated_at();

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA notclal TO notclal_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA notclal TO notclal_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA notclal TO notclal_admin;

-- Verify setup
SELECT 'Database initialization completed successfully' AS status;