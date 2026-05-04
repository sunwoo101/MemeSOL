#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "No .env found. Running setup first..."
    bash "$SCRIPT_DIR/setup-env.sh"
fi

echo "Starting database..."
docker compose -f "$SCRIPT_DIR/docker-compose.yml" up -d

echo "✅ Database is running. You can manage or stop it via Docker Desktop."
