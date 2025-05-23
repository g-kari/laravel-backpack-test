# Laravel Backpack Setup Instructions

This repository provides a Docker-based environment for evaluating Laravel Backpack CMS. Follow these steps to get started:

## Prerequisites

- Docker and Docker Compose installed on your system
- Git

## Quick Setup

1. Clone the repository:
```
git clone https://github.com/g-kari/laravel-backpack-test.git
cd laravel-backpack-test
```

2. Run the setup script which will start Docker containers and install Laravel Backpack:
```
./setup.sh
```

3. Once the setup is complete, access the Laravel Backpack admin panel:
```
http://localhost/admin
```

4. Login with the following credentials:
```
Email: admin@example.com
Password: password
```

## Manual Setup

If you prefer to set up the environment manually:

1. Start the Docker containers:
```
docker-compose up -d
```

2. Run the setup script inside the container:
```
docker-compose exec app bash -c "bash /var/www/setup-laravel-backpack.sh"
```

## Environment Details

- **PHP-FPM**: PHP 8.2 with common extensions for Laravel
- **Nginx**: Latest stable version configured to serve Laravel
- **MySQL**: Version 8.0 with persistent storage
- **Valkey**: Redis-compatible in-memory data store

## Database Connection

- Host: `localhost` (from host) or `db` (from containers)
- Port: `3306`
- Username: `backpack`
- Password: `secret`
- Database: `laravel_backpack`

## About Laravel Backpack

Laravel Backpack is an admin panel for Laravel applications. It provides a set of tools to build custom admin panels quickly.

**Note:** Laravel Backpack is free for non-commercial use. Commercial use requires purchasing a license from the [Laravel Backpack website](https://backpackforlaravel.com/).

## CRUD Demo

This setup includes a sample Product CRUD for demonstration purposes:

- List, create, update, and delete product records
- Product fields include name, description, price, and quantity
- Sample data is automatically added during setup

## Troubleshooting

If you encounter any issues:

1. Check Docker container logs:
```
docker-compose logs
```

2. Verify all containers are running:
```
docker-compose ps
```

3. Restart the containers:
```
docker-compose restart
```

4. For permission issues, you might need to fix permissions:
```
docker-compose exec app bash -c "chown -R www:www /var/www && chmod -R 775 /var/www/storage /var/www/bootstrap/cache"
```