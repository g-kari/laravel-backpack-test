#!/bin/bash
set -e

# Print header
echo "==========================================="
echo "   Laravel Backpack Setup Script"
echo "==========================================="

# Check if docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose first."
    echo "You can install it following instructions at: https://docs.docker.com/compose/install/"
    exit 1
fi

# Start Docker containers
echo "Starting Docker containers..."
docker-compose up -d

# Wait for containers to be ready
echo "Waiting for containers to be ready..."
sleep 5

# Execute the setup script inside the container
echo "Setting up Laravel with Backpack CRUD..."
docker-compose exec -T app bash -c "bash /var/www/setup-laravel-backpack.sh"

# Final message
echo "==========================================="
echo "Setup completed successfully!"
echo ""
echo "Access Laravel Backpack admin panel at:"
echo "http://localhost/admin"
echo ""
echo "Login credentials:"
echo "Email: admin@example.com"
echo "Password: password"
echo "==========================================="