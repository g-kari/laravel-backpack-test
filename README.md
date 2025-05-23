# Statamic-test

## Docker Development Environment

This repository includes a complete Docker-based development environment with PHP-FPM, Nginx, MySQL, and Valkey (Redis fork).

### Prerequisites

- Docker and Docker Compose installed on your system
- Git

### Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/g-kari/Statamic-test.git
   cd Statamic-test
   ```

2. Start the Docker containers:
   ```
   docker-compose up -d
   ```

3. Access the application in your browser:
   ```
   http://localhost
   ```

### Environment Details

- **PHP-FPM**: PHP 8.2 with common extensions required for Laravel/Statamic
- **Nginx**: Latest stable version configured to serve PHP applications
- **MySQL**: Version 8.0 with persistent storage
- **Valkey**: Redis-compatible in-memory data store

### Database Connection

- Host: `localhost` (from host) or `db` (from containers)
- Port: `3306`
- Username: `statamic`
- Password: `secret`
- Database: `statamic`

### Valkey Connection

- Host: `localhost` (from host) or `valkey` (from containers)
- Port: `6379`

### Troubleshooting

If you encounter any issues:

1. Check container logs:
   ```
   docker-compose logs
   ```

2. Verify all containers are running:
   ```
   docker-compose ps
   ```

3. Restart all containers:
   ```
   docker-compose restart
   ```