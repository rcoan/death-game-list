#!/bin/bash

echo "Starting PostgreSQL container..."
docker-compose up -d postgres

echo "Waiting for PostgreSQL to be ready..."
sleep 5

echo "Creating database..."
rails db:create

echo "Running migrations..."
rails db:migrate

echo "Seeding database..."
rails db:seed

echo "Database setup complete!"
echo ""
echo "Admin user created:"
echo "  Email: admin@example.com"
echo "  Password: password123"

